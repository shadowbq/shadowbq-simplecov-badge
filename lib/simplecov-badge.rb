# Ensure we are using a compatible version of SimpleCov
if Gem::Version.new(SimpleCov::VERSION) < Gem::Version.new("0.7.1")
  raise RuntimeError, "The version of SimpleCov you are using is too old. Please update with `gem install simplecov` or `bundle update simplecov`"
end

ImageMagickError = Class.new(StandardError)
  
class SimpleCov::Formatter::BadgeFormatter  
  # Set up config variables.
  options = {:strength_indicator_title => 'TEST COVERAGE', :generate_groups => true, :timestamp => false, :green => '#4fb151',
            :yellow => '#ded443', :red => '#a23e3f', :number_font => 'Helvetica-Narrow-Bold',
            :number_font_size => 20, :name_font => 'Helvetica', :name_font_size => 17,
            :badge_height => 25, :use_strength_color => true, :strength_foreground => false,
            :group_number_font => 'Helvetica-Narrow-Bold', :group_number_font_size => 20,
            :group_name_font => 'Helvetica-Bold', :group_name_font_size => 17,
            :group_badge_height => 25, :use_strength_color_for_group_name => true, 
            :group_strength_foreground => true}
    
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
    command = []
    command[0] = """
      convert -size 52x#{@@badge_height} xc:'#{coverage_color(overall_cov)}' -pointsize #{@@number_font_size} -font '#{@@number_font}' \
      -gravity east -fill white -draw \"kerning 2 text +2,+2 '#{overall_cov}%'\" \
      -alpha set -bordercolor none -border 3 \
      -gravity North -chop 0x3 \
      -gravity South -chop 0x3 \
      -gravity West -chop 3x0 \
      #{output_path}/tmp.png
      """
    command[1] = """
      convert #{output_path}/tmp.png \\( -size 237x#{@@badge_height} xc:'#{strength_background(overall_strength, @@strength_foreground)}' \
      -pointsize #{@@name_font_size} -fill '#{strength_foreground(overall_strength, @@strength_foreground)}' -font '#{@@name_font}' \
      -draw \"kerning 1 text 4,19 '#{strength_indicator_title}'\" \
      -gravity West \
      -background white -splice 1x0  -background black -splice 1x0 \
      -trim  +repage -gravity West -chop 1x0 -gravity East \
      -background '#{strength_background(overall_strength, @@strength_foreground)}' -splice 2x0 \\) \
      -background none +append #{output_path}/tmp.png
      """
    command[2] = """
      convert #{output_path}/tmp.png -format 'roundrectangle 1,1 %[fx:w+4],%[fx:h+#{@@badge_height}] 10,10' \
      -write info:#{output_path}/tmp.mvg \
      -alpha set -bordercolor none -border 3 \
      \\( +clone -alpha transparent -background none \
      -fill white -stroke none -strokewidth 0 -draw @#{output_path}/tmp.mvg \\) \
      -compose DstIn -composite \
      -gravity South -chop 0x3 #{output_path}/tmp.png
      """
    command[3] = """
      convert #{output_path}/tmp.png \\( +clone -alpha extract \
      \\( -size 5x2 xc:black -draw 'fill white circle 8,8 8,0' -write mpr:arc +delete \\) \
      \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) \
      -alpha off -compose CopyOpacity -composite #{output_path}/coverage-badge.png
      """
    begin
      command.each do |cmd|
        output = `#{cmd}`
        check_status(output)
      end
    ensure
      system("rm #{output_path}/tmp.mvg")
      system("rm #{output_path}/tmp.png")
    end
  end
  
  def generate_group_badges(result)
    result.groups.each do |name, files|
      cov = files.covered_percent.round(0)
      strength = files.covered_strength.round(0)
      command = []
      command[0] = """
        convert -size 52x#{@@group_badge_height} xc:'#{coverage_color(cov)}' -pointsize #{@@group_number_font_size} -font '#{@@group_number_font}' \
        -gravity east -fill white -draw \"kerning 2 text +2,+2 '#{cov}%'\" \
        -alpha set -bordercolor none -border 3 \
        -gravity North -chop 0x3 \
        -gravity South -chop 0x3 \
        -gravity East -chop 3x0 #{output_path}/tmp.png
      """
      command[1] = """
        convert #{output_path}/tmp.png \\( -size 300x#{@@group_badge_height} xc:#{strength_background(strength, @@group_strength_foreground)} \
        -pointsize #{@@group_name_font_size} -fill '#{strength_foreground(strength, @@group_strength_foreground)}' -font '#{@@group_name_font}' \
        -draw \"kerning 0.5 text 4,19 '#{name.upcase}'\" \
        -gravity West -background white -splice 1x0 -background black -splice 1x0 \
        -trim  +repage -gravity West -chop 1x0 -gravity East \
        -background '#{strength_background(strength, @@group_strength_foreground)}' -splice 2x0 \
        -alpha set -bordercolor none -border 3 \
        -gravity North -chop 0x3 -gravity South -chop 0x3 \
        -strokewidth 2 -format 'stroke white line 1,1 %[fx:w],3' \\) \
        -background none +append #{output_path}/tmp.png
      """
      command[2] = """
        convert #{output_path}/tmp.png \\( +clone -alpha extract \
        \\( -size 5x2 xc:black -draw 'fill white circle 8,8 8,0' -write mpr:arc +delete \\) \
        \\( mpr:arc -flip \\) -gravity southwest -composite \
        \\( mpr:arc -rotate 180 \\) -gravity southeast -composite \\) \
        -alpha off -compose CopyOpacity -composite \
        #{output_path}/tmp.png
      """
      command[3] = """
        convert #{output_path}/coverage-badge.png #{output_path}/tmp.png -gravity West -background none -append #{output_path}/coverage-badge.png
      """
      begin
        command.each_with_index do |cmd, y|
          next cmd if y == 2 #and i != result.groups.count
          output = `#{cmd}`
          check_status(output)
        end
      ensure
        system("rm #{output_path}/tmp.png")
      end
    end
    if @@timestamp
      timestamp_cmd = """
        convert #{output_path}/coverage-badge.png -alpha set -bordercolor none -border 3 \
        -gravity North -chop 0x3 \
        -gravity East -chop 3x0 \
        -gravity West -chop 3x0 \\( -background none -font 'Helvetica' label:'Generated #{Time.current.strftime('%m-%d-%y %H:%M UTC')}' \\) -background none -gravity center -append #{output_path}/coverage-badge.png
      """
      output = `#{timestamp_cmd}`
      check_status(output)
    end
  end

  # checks if imagemagick is installed and working
  def check_imagemagick
    output = `convert`
    raise ImageMagickError, "ImageMagick doesn't appear to be installed." unless $?.to_i == 0
  end
  
  def check_status(output)
    raise ImageMagickError, "ImageMagick exited with an error. It said:\n #{output}" unless $?.to_i == 0
  end
  
  def output_message(result)
    "Coverage badge generated for #{result.command_name} to #{output_path}."
  end
  
  def output_path
    SimpleCov.coverage_path
  end

  def strength_background(strength, foreground)
    if foreground
      'transparent'
    else
      strength_color(strength, @@use_strength_color)
    end
  end
  
  def strength_foreground(strength, foreground)
    unless foreground
      'white'
    else
      strength_color(strength, @@use_strength_color)
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

  def strength_color(covered_strength, use)
    if use
      if covered_strength > 1
        @@green
      elsif covered_strength == 1
        @@yellow
      else
        @@red
      end
    else
      'silver'
    end
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
require 'simplecov-badge/version'
