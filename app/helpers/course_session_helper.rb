module CourseSessionHelper
  def course_session_params
    out_params = params.require(:session).permit(:name, :start_time, :end_time, :address, :description)
    out_params[:start_time] = Time.at(out_params[:start_time])
    out_params[:end_time] = Time.at(out_params[:end_time])
    out_params
  end

  def show_course_sessions
    @course_sessions = Session.where(course_id: params[:course_id]).order(:start_time)
    if @course_sessions
      render "objects/course_session.json"
    else
      @msg = "Error in generating object"
      @details = "sessions for the course are not found"
      render "objects/msg.json", status: :bad_request and return
    end

  end

  def show_course_session_instructor
    course_instructor = CourseInstructor.find_by(course_id: params[:course_id], user: @user)
    @course_sessions = Session.where(course_id: params[:course_id], course_instructor: course_instructor).order(:start_time)
    if @course_sessions
      render "objects/course_session.json"
    else
      @msg = "Error in generating object"
      @details = "no sessions for the instructor under this course are found"
      render "objects/msg.json", status: :bad_request and return
    end

  end

  def show_course_session
    @course_session = Session.find(params[:session_id])
    if @course_session != nil
      render 'objects/course_session.json'
    else
      @msg = "Error in updating course"
      @details = @course_session.errors
      render "objects/msg.json", status: :bad_request
    end

  end

  def create_session
    course_instructor = CourseInstructor.find_by(course_id: params[:course_id], user: @user)
    @course_session = Session.new(course_session_params)
    # @course_session.start_time = @course_session.start_time
    # @course_session.end_time = @course_session.end_time
    @course_session.course_instructor = course_instructor
    @course_session.course_id = params[:course_id]
    if @course_session.state == 'future'#@course_session.start_time < @course_session.end_time && @course_session.start_time< Time.now
      if @course_session.save
        render 'objects/course_session.json'
      else
        @msg = "Error in generating course"
        @details = @course_session.errors
        render "objects/msg.json", status: :bad_request
      end
    else
      @msg = "Cannot create past sesions check time entry"
      @details = @course_session.errors
      render "objects/msg.json", status: :bad_request
    end
  end

  def update_session
    course_session_new = Session.new(course_session_params)
    @course_session = Session.find(params[:session_id])# find session by its id.
    if @course_session.state != "past" && course_session_new.state == "future"
      @course_session.start_time = course_session_new.start_time
      @course_session.end_time = course_session_new.end_time
    else
      @msg = "Check the times you have entered"
      render "objects/msg.json", status: :bad_request and return
    end
    if @course_session.save
      @msg = "session succesfult saved to db."
      render 'objects/course_session.json'
    else
      @msg = "Error in updating course"
      @details = @course_session.errors
      render "objects/msg.json", status: :bad_request
    end

  end

  def delete_session
    found_session = Session.find(params[:session_id])
    if found_session == nil
      @msg = "Error in deleting session"
      render "objects/msg.json", status: :bad_request
    else
      found_session.destroy
      @msg = "Acknowledged"
      render "objects/msg.json"
    end
  end

  def end_session
    @course_session = Session.find(params[:session_id])# need to check
    if @course_session == nil || @course_session.state != "present"
      @msg = "Error in ending session"
      render "objects/msg.json", status: :bad_request and return
    end
    @course_session.end_time = Time.now
    if @course_session.save
      render 'objects/course_session.json'
    else
      @msg = "Error in generating course"
      @details = @course_session.errors
      render "objects/msg.json", status: :bad_request
    end
  end
end