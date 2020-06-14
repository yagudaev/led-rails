class Setting < ApplicationRecord
  before_save :run_program

  PATH_TO_DEMOS = '/home/pi/Documents/rpi-rgb-led-matrix/examples-api-use'.freeze

  # TODO: try putting in a group and exiting
  def run_program
    kill_previous if pid
    pid = fork do
      Process.setsid
      exec "#{PATH_TO_DEMOS}/demo -D1 --led-rows=64 --led-cols=64 --led-slowdown-gpio=1 --led-scan-mode=0 --led-pixel-mapper=\"Rotate:90\" --led-brightness=10 #{PATH_TO_DEMOS}/pictures/strawberry.ppm -m 0"
    end
    sleep 0.1
    Process.detach(pid)

    self.pid = pid
  end

  def kill_previous
    pgid = Process.getpgid(pid)
    Process.kill('INT', -pgid)
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
