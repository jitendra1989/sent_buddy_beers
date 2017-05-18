require 'net/https'
require 'timeout'

class DeletePendingBarJob < Struct.new(:bar_id)
  TIMEOUT_SECONDS = 180

  def perform
    Timeout::timeout(TIMEOUT_SECONDS) do
      bar = Bar.find(bar_id)
      bar.destroy() if bar.pending and bar.inactive?
    end
  end
end
