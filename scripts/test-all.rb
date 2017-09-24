require "timeout"

require "parallel"

class Tester
  IMAGES = %w(
    centos-6
    centos-7
    debian-8
    debian-9
    ubuntu-1404-lts
    ubuntu-1604-lts
    ubuntu-1704
  ).freeze
  IMAGES = %w(
    ubuntu-1604-lts
  )
  SCRIPT_URL = "https://gist.githubusercontent.com/nownabe/6f90da65c3a38364a7d9981316cd7d40/raw/test_gems.sh"

  attr_reader :branch
  attr_reader :enable_shared

  def initialize(branch:, enable_shared:)
    @branch  = branch
    @enable_shared = enable_shared
  end

  def run
    puts "* #{branch} / enable_shared: #{enable_shared} (#{log})"
    Parallel.each(images, in_threads: images.size) do |image|
      image_project = `gcloud compute images list | grep #{image} | awk '{ print $2 }'`.chomp

      cmd = %W[
        gcloud compute instances create
        gem-tester-#{image}
        --boot-disk-size 50GB
        --machine-type n1-highcpu-8
        --zone asia-northeast1-a
        --image-project #{image_project}
        --image-family #{image}
      ].join(" ")
      exec(cmd)

      begin
        Timeout.timeout(120) do
          loop do
            cmd = "gcloud compute ssh gem-tester-#{image} --zone asia-northeast1-a --command \"hostname\""
            ret = exec(cmd)
            break if ret.success?
            sleep 5
          end
        end
      rescue Timeout::Error
        puts "#{image} - Failed! (instances didn't start)"
        raise Parallel::Break
      end

      test_command = %W[
        curl -LsS
        #{SCRIPT_URL}
        | BRANCH=#{branch}
        CONFIGURE_OPTIONS=#{enable_shared? ? "--enable-shared" : ""}
        bash
      ].join(" ")

      cmd = %W[
        gcloud compute ssh
        gem-tester-#{image}
        --zone asia-northeast1-a
        --command "#{test_command}"
        -- -t
      ].join(" ")

      ret = exec(cmd)

      if ret.success?
        puts "#{image} - Succeeded!"
      else
        puts "#{image} - Failed!"
      end

      cmd = %W[
        yes |
        gcloud compute instances delete
        gem-tester-#{image}
        --delete-disks all
        --zone asia-northeast1-a
      ].join(" ")

      exec(cmd)
    end
  end

  private

  def enable_shared?
    !!enable_shared
  end

  def exec(cmd)
    `echo >>#{log}`
    `echo '$ #{cmd}' >>#{log}`
    `#{cmd} >>#{log} 2>&1`
    $?
  end

  def images
    # IMAGES
    ["ubuntu-1604-lts"]
  end

  def log
    @log ||= "logs/#{branch}#{enable_shared? ? "-enable-shared" : ""}.log"
  end
end

Tester.new(branch: "gem_tester-trunk", enable_shared: true).run
Tester.new(branch: "gem_tester-trunk", enable_shared: false).run
Tester.new(branch: "gem_tester-2.4.2", enable_shared: true).run
Tester.new(branch: "gem_tester-2.4.2", enable_shared: false).run
