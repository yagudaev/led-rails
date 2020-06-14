class Setting < ApplicationRecord
  before_save :run_program

  PATH_TO_DEMOS = '~/Documents/rpi-rgb-led-matrix/examples-api-use'.freeze

  def run_program
    kill_previous if pid
    o, e, s = Open3.capture3 `sudo #{PATH_TO_DEMOS}/demo -D1 --led-rows=64 --led-cols=64 --led-slowdown-gpio=1 --led-scan-mode=0 --led-pixel-mapper="Rotate:90" --led-brightness=10 --led-daemon #{PATH_TO_DEMOS}/pictures/strawberry.ppm -m 0`
    puts o
    puts e

    self.pid = s.pid
  end

  def kill_previous
    output = `sudo kill -9 #{pid}`
    puts output
  end
end
