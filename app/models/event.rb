class Event < ActiveRecord::Base
  belongs_to :user
  attr_accessor :other_event_type
  #validates_presence_of :title, :day_of_the_event
  scope :find_comming_events, lambda { |beginning_date, end_date| where("day_of_the_event >= ? AND day_of_the_event <= ?", beginning_date, end_date) }

  EVENT_TYPE = ['Anniversary', 'Birthday', 'Just Because', 'Other']
end
