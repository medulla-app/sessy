module Sessy
module Source::Colors
  extend ActiveSupport::Concern

  CLASSES = {
    "purple" => "bg-purple-400",
    "blue" => "bg-sky-400",
    "cyan" => "bg-cyan-300",
    "green" => "bg-emerald-400",
    "red" => "bg-red-400",
    "orange" => "bg-orange-400",
    "yellow" => "bg-yellow-400",
    "gray" => "bg-gray-400"
  }.freeze

  ALL = CLASSES.keys.freeze

  included do
    validates :color, inclusion: { in: ALL }
  end

  class_methods do
    def next_available_color
      color_counts = group(:color).count
      ALL.min_by { |color| color_counts[color] || 0 }
    end
  end

  def color_class
    CLASSES[color] || CLASSES["blue"]
  end
end
end
