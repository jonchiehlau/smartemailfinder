class FullContactException < StandardError
  def initialize(data)
    @data = data
  end

  def message
    @data.to_s
  end
end