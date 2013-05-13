require 'erb'
require 'cgi'
require 'fileutils'
require 'digest/sha1'
require 'time'

# Ensure we are using a compatible version of SimpleCov
if Gem::Version.new(SimpleCov::VERSION) < Gem::Version.new("0.7.1")
  raise RuntimeError, "The version of SimpleCov you are using is too old. Please update with `gem install simplecov` or `bundle update simplecov`"
end

class SimpleCov::Formatter::ReadmeFormatter
  def format(result)
    # Dir[File.join(File.dirname(__FILE__), '../public/*')].each do |path|
    #   FileUtils.cp_r(path, asset_output_path)
    # end

    # File.open(File.join(Rails.root, "README.md"), "a+") do |file|
    #   file.puts template('readme_layout').result(binding)
    # end
    
    generate_badges(result)
    
    puts output_message(result)
  end

  def output_message(result)
    "Coverage report generated for #{result.command_name} to #{output_path}. #{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered."
  end

  private
  
  # generates badges using ImageMagick
  def generate_badges(result)
    overall_cov = result.source_files.covered_percent.round(2)
    overall_strength = result.covered_strength.round(2)
    command = "convert -size 237x30 xc:#{coverage_css_class(overall_cov)} -draw \"fill silver rectangle 47,0 237,30\" \
      -strokewidth 2 -draw \"stroke white line 47,0 47,30\" -pointsize 22 \
      -font 'Helvetica-Narrow-Bold' -fill white -draw \"kerning 2 text 3,22 '98%'\" \
      -pointsize 19 -fill white -font 'Helvetica' -draw \"kerning 1 text 51,22 'CODE COVERAGE'\" \
      -format 'roundrectangle 1,1 %[fx:w+10],%[fx:h+4] 10,10' \
            -write info:tmp.mvg \
            -alpha set -bordercolor none -border 3 \
            \( +clone -alpha transparent -background none \
               -fill white -stroke none -strokewidth 0 -draw @tmp.mvg \) \
            -compose DstIn -composite ./coverage/coverage-badge.png"
      # convert -size 237x30 xc:#{coverage_css_class(overall_cov)} -draw 'fill silver rectangle 47,0 237,30' \
      #           -strokewidth 2 -draw 'stroke white line 47,0 47,30' \
      #           -pointsize 22 -font 'Helvetica-Narrow-Bold' \
      #           -fill white -draw \"kerning 2 text 3,22 '98%'\" \
      #           -pointsize 19 -fill white -font 'Helvetica' \
      #           -draw \"kerning 1 text 51,22 'CODE COVERAGE'\" \
      #           -format 'roundrectangle 1,1 %[fx:w+10],%[fx:h+4] 10,10' \
      #           -write info:tmp.mvg \
      #           -alpha set -bordercolor none -border 3 \
      #           \( +clone -alpha transparent -background none \
      #              -fill white -stroke none -strokewidth 0 -draw @tmp.mvg \) \
      #           -compose DstIn -composite ./coverage/coverage-badge.png
      #           "
    if system(command)
      system('rm tmp.mvg')
    else
      return false
    end
    result.groups.each do |name, files|
      cov = result.source_files.covered_percent.round(2)
      strength = result.covered_strength.round(2)
      command = """
        convert -size 200x30 xc:#{coverage_css_class(cov)} -draw 'fill silver rectangle 47,0 200,30' \
        -strokewidth 2 -draw 'stroke white line 47,0 47,30' \
        -pointsize 22 -font 'Helvetica-Narrow-Bold' \
        -fill white -draw \"kerning 2 text 3,22 '98%'\" \
        -pointsize 19 -fill white -font 'Helvetica' \
        -draw \"kerning 1 text 51,22 '#{name}'\" \
        -format 'roundrectangle 1,1 %[fx:w+10],%[fx:h+4] 10,10' \
        -write info:tmp.mvg \
        -alpha set -bordercolor none -border 3 \
        \( +clone -alpha transparent -background none \
           -fill white -stroke none -strokewidth 0 -draw @tmp.mvg \) \
        -compose DstIn -composite ./coverage/coverage-badge.png
        """
        if system(command)
          system('rm tmp.mvg')
        else
          return false
        end
    end
  end
  

  # Returns the an erb instance for the template of given name
  def template(name)
    ERB.new(File.read(File.join(File.dirname(__FILE__), '../views/', "#{name}.erb")))
  end

  def output_path
    SimpleCov.coverage_path
  end

  def asset_output_path
    return @asset_output_path if defined? @asset_output_path and @asset_output_path
    @asset_output_path = File.join(output_path, 'assets', SimpleCov::Formatter::ReadmeFormatter::VERSION)
    FileUtils.mkdir_p(@asset_output_path)
    @asset_output_path
  end

  def assets_path(name)
    File.join('./assets', SimpleCov::Formatter::ReadmeFormatter::VERSION, name)
  end

  # Returns the html for the given source_file
  def formatted_source_file(source_file)
    template('source_file').result(binding)
  end

  # Returns the html badge for the given group
  def badge(name, source_files)
    template('badge').result(binding)
  end
  
  # Returns a table containing the given source files
  def formatted_file_list(title, source_files)
    title_id = title.gsub(/^[^a-zA-Z]+/, '').gsub(/[^a-zA-Z0-9\-\_]/, '')
    template('file_list').result(binding)
  end

  def coverage_css_class(covered_percent)
    if covered_percent > 90
      'green'
    elsif covered_percent > 80
      'yellow'
    else
      'red'
    end
  end

  def strength_css_class(covered_strength)
    if covered_strength > 1
      'green'
    elsif covered_strength == 1
      'yellow'
    else
      'red'
    end
  end

  # Return a (kind of) unique id for the source file given. Uses SHA1 on path for the id
  def id(source_file)
    Digest::SHA1.hexdigest(source_file.filename)
  end

  def timeago(time)
    "<abbr class=\"timeago\" title=\"#{time.iso8601}\">#{time.iso8601}</abbr>"
  end

  def shortened_filename(source_file)
    source_file.filename.gsub(SimpleCov.root, '.').gsub(/^\.\//, '')
  end

  def link_to_source_file(source_file)
    %Q(<a href="##{id source_file}" class="src_link" title="#{shortened_filename source_file}">#{shortened_filename source_file}</a>)
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
require 'simplecov-readme/version'
