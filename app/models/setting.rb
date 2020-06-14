class Setting < ApplicationRecord
  before_save :run_program

  PATH_TO_DEMOS = '/home/pi/Documents/rpi-rgb-led-matrix/examples-api-use'.freeze

  IMAGES = %i[eye.ppm malibu.ppm runtext16.ppm runtext.ppm strawberry.ppm white-ascii.ppm white.ppm].freeze

  store_accessor :args, :image
  store_accessor :args, :brightness
  store_accessor :args, :movement

  def run_program
    kill_previous if pid
    pid = fork do
      Process.setsid
      exec "#{PATH_TO_DEMOS}/demo -D#{program || 1} --led-rows=64 --led-cols=64 --led-slowdown-gpio=1 --led-scan-mode=0 --led-pixel-mapper=\"Rotate:90\" --led-brightness=#{brightness || 10} #{PATH_TO_DEMOS}/pictures/#{image || 'strawberry.ppm'} -m #{movement || 0}"
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
end
