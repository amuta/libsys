module JsonHelper
  def json = JSON.parse(response.body, symbolize_names: true)
end
RSpec.configure { |c| c.include JsonHelper }
