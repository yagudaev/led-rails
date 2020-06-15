class Setting < ApplicationRecord
  before_save :run_program

  PATH_TO_DEMOS = '/home/pi/Documents/rpi-rgb-led-matrix/examples-api-use'.freeze

  IMAGES = %i[eye.ppm malibu.ppm runtext16.ppm runtext.ppm strawberry.ppm white-ascii.ppm white.ppm].freeze
  PROGRAMS = [
    ['image-scroll-left', 1],
    ['image-scroll-right', 2],
    ['image-test-square', 3],
    ['pulsing-color', 4],
    ['greyscale-block', 5],
    ['abelian-sandpile-model', 6],
    ['conways-game-of-life', 7],
    ['langtons-ant', 8],
    ['volume-bars', 9],
    ['evolution-of-color', 10],
    ['pulsing-brightness', 11]
  ]

  store_accessor :args, :image
  store_accessor :args, :brightness
  store_accessor :args, :movement

  has_one_attached :local_image

  def run_program
    kill_previous if pid
    pid = fork do
      Process.setsid
      cmd_image = local_image_ppm_on_disk || "#{PATH_TO_DEMOS}/pictures/#{image || 'strawberry.ppm'}"
      cmd = "#{PATH_TO_DEMOS}/demo -D#{program || 1} --led-rows=64 --led-cols=64 --led-slowdown-gpio=1 --led-scan-mode=0 --led-pixel-mapper=\"Rotate:90\" --led-brightness=#{brightness || 10} #{cmd_image} -m #{movement || 0}"
      puts "[CMD] #{cmd}"
      exec cmd
    end
    sleep 0.1
    Process.detach(pid)

    self.pid = pid
  end

  def kill_previous
    pgid = Process.getpgid(pid)
    Process.kill('HUP', -pgid)
  rescue Errno::ESRCH => e
    puts "warning: couldn't find process #{pid}"
  end

  def run(cmd)
    puts "[CMD] #{cmd}"
    if ENV['SIMULATE']
      o, e, s = Open3.capture3 "echo \"#{cmd}\""
    else
      o, e, s = Open3.capture3 cmd
    end

    puts o if o.present?
    puts e if e.present?

    s
  end

  def local_image_on_disk
    ActiveStorage::Blob.service.send(:path_for, local_image.key) if local_image.attached?
  end

  def local_image_ppm
    local_image.variant(convert: 'ppm') if local_image.attached?
  end

  def local_image_ppm_on_disk
    return unless local_image.attached?

    local_image_ppm.processed
    ActiveStorage::Blob.service.send(:path_for, local_image_ppm.key)
  end
end
