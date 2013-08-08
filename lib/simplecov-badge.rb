# Ensure we are using a compatible version of SimpleCov
if Gem::Version.new(SimpleCov::VERSION) < Gem::Version.new("0.7.1")
  raise RuntimeError, "The version of SimpleCov you are using is too old. Please update with `gem install simplecov` or `bundle update simplecov`"
end

ImageMagickError = Class.new(StandardError)
  
class SimpleCov::Formatter::BadgeFormatter  
  # Set up config variables.
  options = {:badge_title => 'TEST COVERAGE', :generate_groups => true, :timestamp => false, :green => '#4fb151',
            :yellow => '#ded443', :red => '#a23e3f', :number_font => 'Helvetica-Narrow-Bold',
            :number_font_size => 20, :name_font => 'Helvetica', :name_font_size => 17,
            :badge_height => 27, :strength_foreground => false,
            :group_number_font => 'Helvetica-Narrow-Bold', :group_number_font_size => 18,
            :group_name_font => 'Helvetica-Bold', :group_name_font_size => 15,
            :group_badge_height => 22, :group_strength_foreground => false, :color_code_title => true,
            :group_color_code_title => true}
    
  # set up class variables and getters/setters
  options.each do |opt,v|
    set = "@@#{opt} = v"
    getter = "def self.#{opt};  @@#{opt}; end;"
    setter = "def self.#{opt}=(value);  @@#{opt} = value; end;"
    eval(set)
    eval(getter)
    eval(setter)
  end
  
  def format(result)
    begin
      check_imagemagick
      generate_header_badge(result)
      generate_group_badges(result) if @@generate_groups
      generate_timestamp if @@timestamp
      puts output_message(result)
    rescue ImageMagickError => e
     puts e
     puts "Simplecov-Badge was unable to generate a badge for #{result.command_name}."
    end
  end

  private
  
  def generate_header_badge(result)
    overall_cov = result.source_files.covered_percent.round(0)
    overall_strength = result.covered_strength.round(0)
    generator(overall_cov, overall_strength, false)
  end
  
  def generate_group_badges(result)
    result.groups.each do |name, files|
      cov = files.covered_percent.round(0)
      strength = files.covered_strength.round(0)
      generator(cov, strength, name)
    end
  end
  
  def generator(cov, strength, group)
    command = []
    command[0] = """
      convert -size 52x#{get_config('badge_height', group)} xc:'#{coverage_color(cov)}' -pointsize #{get_config('number_font_size', group)} -font \"#{get_config('number_font', group)}\" \
      -gravity center -fill white -draw \"kerning 2 text +2,-1 '#{cov}%'\" \
      -pointsize 10 -font \"#{get_config('number_font', group)}\" \
      -gravity south -fill white -draw \"text 0,-1 'coverage'\" \
      -alpha set -bordercolor none -border 3 \
      -gravity North -chop 0x3 \
      -gravity South -chop 0x3 \
      -gravity West -chop 3x0 \
      #{output_path}/tmp.png
      """
    command[1] = """
      convert #{output_path}/tmp.png \\( -size 260x#{get_config('badge_height', group)} xc:\"#{title_background(cov, strength, get_config('strength_foreground', group), get_config('color_code_title', group))}\" \
      -pointsize #{get_config('name_font_size', group)} -fill \"#{title_foreground(cov, strength, get_config('strength_foreground', group), get_config('color_code_title', group))}\" -font \"#{get_config('name_font', group)}\" \
      -draw \"kerning 1 text #{group ? 2 : 4},#{group ? 16 : 19} '#{group ? group.upcase : @@badge_title}'\" \
      -gravity West -background white -splice 1x0  \
      -background black -splice 1x0 -trim  +repage \
      -gravity West -chop 1x0 -gravity East \
      -background \"#{title_background(cov, strength, get_config('strength_foreground', group), get_config('color_code_title', group))}\" -splice 3x0 \\) \
      -background none +append #{output_path}/tmp.png
      """
    command[2] =   """
        convert #{output_path}/tmp.png \\( -size 52x#{get_config('badge_height', group)} xc:\"#{strength_background(strength, get_config('strength_foreground', group))}\" -pointsize #{get_config('number_font_size', group)} -font \"#{get_config('number_font', group)}\" \
        -gravity Center -fill white -draw \"kerning 2 text 0,-1 '#{strength}'\" \
        -pointsize 10 -font \"#{get_config('number_font', group)}\" \
        -gravity south -fill white -draw \"text 0,-1 'hits/line'\" \
        -alpha set -bordercolor none -border 3 \
        -gravity North -chop 0x3 \
        -gravity South -chop 0x3 \
        -gravity East -chop 3x0 \\) \
        -background none +append #{output_path}/tmp.png
        """
    command[3] = """
      convert #{output_path}/tmp.png -format 'roundrectangle 1,1 %[fx:w+4],%[fx:h+4] 10,10' \
      -write info:#{output_path}/tmp.mvg \
      -alpha set -bordercolor none -border 3 \
      \\( +clone -alpha transparent -background none \
      -fill white -stroke none -strokewidth 0 -draw @#{output_path}/tmp.mvg \\) \
      -compose DstIn -composite \
      -gravity South -chop 0x1 #{output_path}/tmp.png
      """
    command[4] = """
      convert #{output_path}/tmp.png #{output_path}/coverage-badge.png
      """
    command[5] = """
      convert #{output_path}/coverage-badge.png #{output_path}/tmp.png -background none -gravity center -append #{output_path}/coverage-badge.png
      """
    begin
      command.each_with_index do |cmd, i|
        next i if i == 4 unless group == false
        next i if i == 5 if group == false
        output = `#{cmd}`
        check_status(output)
      end
    ensure
      system("rm #{output_path}/tmp.mvg")
      system("rm #{output_path}/tmp.png")
    end
  end
  
  def generate_timestamp
    timestamp_cmd = """
      convert #{output_path}/coverage-badge.png -alpha set -bordercolor none -border 3 \
      -gravity North -chop 0x3 \
      -gravity East -chop 3x0 \
      -gravity West -chop 3x0 \\( -background none -font 'Helvetica' label:'Generated #{Time.now.strftime('%m-%d-%y %H:%M UTC')}' \\) -background none -gravity center -append #{output_path}/coverage-badge.png
    """
    output = `#{timestamp_cmd}`
    check_status(output)
  end
  
  # getter method for config variables - abstracts group or main badge from generator
  def get_config(name, group)
    if group
      eval("@@group_#{name}")
    else
      eval("@@#{name}")
    end
  end
  
  # checks if imagemagick is installed and working
  def check_imagemagick
    output = `convert`
    raise ImageMagickError, "ImageMagick doesn't appear to be installed." unless $?.to_i == 0
  end
  
  # Checks exit status after running a command with backtick
  def check_status(output)
    raise ImageMagickError, "ImageMagick exited with an error. It said:\n #{output}" unless $?.to_i == 0
  end
  
  def output_message(result)
    "Coverage badge generated for #{result.command_name} to #{output_path}."
  end
  
  def output_path
    SimpleCov.coverage_path
  end

  def title_background(cov, strength, foreground, use)
    if !use
      'silver'
    elsif foreground
      'transparent'
    elsif cov > 90 and strength > 1
      @@green
    elsif cov > 80 and strength >= 1
      @@yellow
    else
      @@red
    end
  end
  
  def title_foreground(cov, strength, foreground, use)
    if !foreground or !use
      'white'
    elsif cov > 90 and strength > 1
      @@green
    elsif cov > 80 and strength >= 1
      @@yellow
    else
      @@red
    end
  end
  
  def strength_background(strength, foreground)
    if foreground
      'transparent'
    else
      strength_color(strength)
    end
  end
  
  def strength_foreground(strength, foreground)
    unless foreground
      'white'
    else
      strength_color(strength)
    end
  end
  
  def coverage_color(covered_percent)
    if covered_percent > 90
      @@green
    elsif covered_percent > 80
      @@yellow
    else
      @@red
    end
  end

  def strength_color(covered_strength)
    if covered_strength > 1
      @@green
    elsif covered_strength == 1
      @@yellow
    else
      @@red
    end
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
require 'simplecov-badge/version'
