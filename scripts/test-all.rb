require "timeout"

require "parallel"

class Tester
  SCRIPT_URL =
    "https://raw.githubusercontent.com/nownabe/gem_tester/master/scripts/run-gem_tester.sh"

  attr_reader :branch
  attr_reader :enable_shared
  attr_reader :image_family

  def initialize(image_family, branch:, enable_shared:)
    @image_family  = image_family
    @branch        = branch
    @enable_shared = enable_shared
  end

  def run
    create_instance
    wait_instance
    run_gem_tester
  ensure
    delete_instance
  end

  private

  def create_instance
    exec(%W[
      gcloud compute instances create
      #{instance_name}
      --boot-disk-size 50GB
      --machine-type n1-highcpu-8
      --zone asia-northeast1-a
      --image-project #{image_project}
      --image-family #{image_family}
    ])
  end

  def delete_instance
    exec(%W[
      yes |
      gcloud compute instances delete
      #{instance_name}
      --delete-disks all
      --zone asia-northeast1-a
    ])
  end

  def enable_shared?
    !!enable_shared
  end

  def exec(*cmd)
    cmd = cmd.join(" ")
    `echo >>#{log}`
    `echo '$ #{cmd}' >>#{log}`
    `#{cmd} >>#{log} 2>&1`
    $?
  end

  def image_project
    @image_project ||=
      `gcloud compute images list | grep #{image_family} | awk '{ print $2 }'`.chomp
  end

  def instance_name
    @instance_name ||= "gem-tester-#{image_family}"
  end

  def log
    @log ||= "logs/#{branch}#{enable_shared? ? "-enable-shared" : ""}-#{image_family}.log"
  end

  def run_gem_tester
    ret = exec(%W[
      gcloud compute ssh
      #{instance_name}
      --zone asia-northeast1-a
      --command "#{test_command}"
      -- -t
    ])

    if ret.success?
      puts "#{image_family} - Succeeded!"
    else
      puts "#{image_family} - Failed!"
    end
  end

  def script_url
    SCRIPT_URL
  end

  def test_command
    %W[
      curl -LsS
      #{script_url}
      | BRANCH=#{branch}
      CONFIGURE_OPTIONS=#{enable_shared? ? "--enable-shared" : ""}
      bash
    ].join(" ")
  end

  def wait_instance
    Timeout.timeout(120) do
      loop do
        ret = exec(%W[
          gcloud compute ssh
          #{instance_name}
          --zone asia-northeast1-a
          --command "hostname"
        ])
        break if ret.success?
        sleep 5
      end
    end
  rescue Timeout::Error
    puts "#{image_family} - Failed! (instances didn't start)"
    raise Parallel::Break
  end
end

class ParallelTester
  # IMAGES = %w(
  #   centos-7
  #   debian-8
  #   debian-9
  #   ubuntu-1404-lts
  #   ubuntu-1604-lts
  #   ubuntu-1704
  # ).freeze
  IMAGES = %w(
    centos-7
    debian-8
    ubuntu-1604-lts
  ).freeze

  attr_reader :branch
  attr_reader :enable_shared

  def initialize(branch:, enable_shared:)
    @branch  = branch
    @enable_shared = enable_shared
  end

  def run
    puts "* #{branch} / enable_shared: #{enable_shared}"
    Parallel.each(images, in_threads: images.size) do |image|
      Tester.new(image, branch: branch, enable_shared: enable_shared).run
    end
  end

  private

  def images
    IMAGES
  end
end

ParallelTester.new(branch: "gem_tester-trunk", enable_shared: true).run
ParallelTester.new(branch: "gem_tester-trunk", enable_shared: false).run
ParallelTester.new(branch: "gem_tester-2.4.2", enable_shared: true).run
ParallelTester.new(branch: "gem_tester-2.4.2", enable_shared: false).run
