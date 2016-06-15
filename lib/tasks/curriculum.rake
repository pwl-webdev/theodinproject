namespace :curriculum do

  desc "Grab Latest Lesson Content from Github"
  task :update_content => :environment do
    # puts "Updating the curriculum..."

    # puts "Creating Github link..."

    github = Github.new do |g|
      g.user        = "theodinproject"
      g.repo        = "curriculum"
      g.oauth_token = "#{ENV['GITHUB_API_TOKEN']}"
    end

    lessons = Lesson.all
    count = lessons.count
    # puts "Cycling through #{count} lessons...\n\n\n"
    lessons.each_with_index do |lesson,i|
      # puts "Retrieving Lesson #{i+1}/#{count}: #{lesson.title}"
      response = github.repos.contents.get :path => lesson.url
      # Decode the gibberish into a real file and render to html
      decoded_file = Base64.decode64(response["content"])

      if decoded_file
        snippet_end = decoded_file.index("\n")-1 || 03
        if lesson.content == decoded_file
          # puts "    ...No new content."
        else
          # puts "    Adding content: \"#{decoded_file[0..snippet_end]}\""
          lesson.content = decoded_file
          lesson.save!
          # puts "Added content to the lesson..."
        end
        # puts
      else
        # puts "\n\n\n\n\n\n FAILED TO ADD CONTENT TO THE LESSON!!!\n\n\n\n\n\n"
        raise "Failed to add content to the lesson (tried to add `nil`)!"
      end
    end

    puts "\nChecking for any nils or blanks in the database"
    Lesson.all.each do |l|
      # print "."
      raise "Nil lesson content error! Lesson was #{l.title}." if l.content.nil?
      raise "Blank lesson content error! Lesson was #{l.title}." if l.content.blank?
    end
    # puts "\n...All lessons appear to have content."
    # puts "...so we're ALL DONE! Updated the curriculum."
  end
<<<<<<< HEAD

  desc "Using multi threading to grab content from https://github.com/TheOdinProject/curriculum"
  task :update_content_dev => :environment do
    puts "Retrieving content... \n"
    github = Github.new do |g|
      g.user        = "theodinproject"
      g.repo        = "curriculum"
      g.oauth_token = "#{ENV['GITHUB_API_TOKEN']}"
    end

    threads = []
    Thread.abort_on_exception = true

    Lesson.all.each do |lesson|
      threads << Thread.new do
        response = github.repos.contents.get :path => lesson.url

        content = Base64.decode64(response["content"])

        raise "no contents" if !content

        if lesson.content == content
          print "-"
        else
          lesson.content = content
          lesson.save!
          print "+"
        end
      end
    end
    threads.map(&:join)
    puts "\nDone..."
  end
end
=======
end
>>>>>>> upstream/implement_progress_tracking
