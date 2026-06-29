module Sessy
module SourceScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_source
  end

  private

  def set_source
    @source = Source.find(params[:source_id])
  end
end
end
