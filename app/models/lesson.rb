class Lesson < ActiveRecord::Base
  attr_accessible :address, :city, :course_id, :start_time, :end_time, :description, :title, :user_id, :slug, :venue_id, :summary, :level_id, :tweet_message

  has_many :attendances
  has_many :users, :through => :attendances
  before_save :generate_slug
  belongs_to :venue
  belongs_to :teacher, class_name: "User"

  def generate_slug
    self.slug = Slug.new(title).generate if self.slug.blank?
  end

  def to_param
    slug || id
  end

  def self.lessons_this_month
    from = Time.current.beginning_of_month
    to = Time.current.end_of_month

    self.where(start_time: (from..to))
  end

  def self.future_lessons
    self.where("end_time > (?)", Time.current).order("start_time asc")
  end

  def self.past_lessons(limit=4)
    lessons = self.where("end_time < (?)", Time.current)
                  .order("RANDOM()").limit(limit)

    if lessons.empty?
      lessons << new
    end

    lessons
  end

  def self.for_school(school)
    self.joins(:venue).where(venues: {school_id: school.id})
  end
end
