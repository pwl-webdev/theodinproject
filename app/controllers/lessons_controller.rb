class LessonsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found_error

  def index
    @course = find_course
  end

  def show
    @course = find_course
    @lesson = find_lesson unless @course.nil?

    if show_ads?
      @lower_banner_ad = true
      @right_box_ad = true
    end
  end

  private

  def find_course
    @find_course ||= Course.find_by(title_url: course_title)
  end

  def find_lesson
    @find_lesson ||= find_course.lessons.find_by(title_url: lesson_title)
  end

  def course_title
    params[:course_name]
    raise ActionController::RoutingError.new('Not Found') unless @course.is_active

    @content = md(@lesson.content) if @lesson.content
    @next_lesson = @lesson.next_lesson
    @prev_lesson = @lesson.prev_lesson
    @num_lessons = @lesson.section.lessons.where(:is_project => false).count
    @num_projects = @lesson.section.lessons.where(:is_project => true).count

    #SPIKE! These two queries run the logic we want - but are by no means final.
    #TODO: Write tests, rewrite this crap :)
    # @completion_ids = @lesson.lesson_completion_ids
    # @current_students = @prev_lesson.lesson_completion_ids.find_all do |completion_id|
    #   User.find(completion_id).send(:latest_completed_lesson).id == @prev_lesson.id
    # end

    # the position of the lesson not including projects
    @lesson_position_in_section = @lesson.section.lessons.where("is_project = ? AND position <= ?", false, @lesson.position).count
    # puts "\n\nVE BANNER #{Ad.show_ads?(current_user)}!\n\n"
    # puts "ENV: #{ENV['SHOW_ADS']}!!\n\n"
    if ENV["SHOW_ADS"] && Ad.show_ads?(current_user)
      @lower_banner_ad = true # Ad.ve_banner
      @right_box_ad = true # Ad.ve_box
    end
    # puts "\n\nVE: #{Ad.all.inspect} \n\nBANNER AD #{Ad.ve_banner}!\n\n"
  end

  def lesson_title
    params[:lesson_name]
  end

  def show_ads?
    ENV["SHOW_ADS"] && Ad.show_ads?(current_user)
  end
end
