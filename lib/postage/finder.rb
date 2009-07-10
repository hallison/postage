module Postage

  # This class is a utility for find all posts in specific directory.
  class Finder

    attr_reader :posts, :tags

    # Finder most be initialized with the directory that contains post files.
    def initialize(directory)
      @files = Dir[File.join(directory, "**.*")]
    end

    def load_all_post_files
      @files.sort.collect do |file_name|
        Post.load(file_name)
      end
    end

    def all_posts
      @posts ||= load_all_post_files
    end

    def all_posts_by_tag(tag)
      all_posts
      @posts.find_all{ |post| post.tags.include?(tag) }
    end

    def post(date, name)
      all_posts
      @posts.find{ |post| post.file.match(%r{#{date.to_args}-#{name}*.*}i) }
    end

    def posts(keywords)
      all_posts
      @posts.find_all{ |post| post.matched? search_expresion(keywords) }
    end

    def all_post_tags
      all_posts
      @tags ||= @posts.collect{ |post| post.tags }.flatten.uniq.sort
    end

    def all_tags
      all_post_tags
    end

    def tag(name)
      all_tags
      @tags.find{ |tag| tag == name }
    end

  private

    def search_expresion(keywords)
      %r{#{keywords.to_s.split(/[ ,\*]/).join('|')}}i
    end

  end # class Finder

end # module Postage

