require 'time'


# Ensure we are using a compatible version of SimpleCov
if Gem::Version.new(SimpleCov::VERSION) < Gem::Version.new("0.7.1")
  raise RuntimeError, "The version of SimpleCov you are using is too old. Please update with `gem install simplecov` or `bundle update simplecov`"
end

class SimpleCov::Formatter::BadgeFormatter
  def format(result)    
    generate_badges(result)
    
    puts output_message(result)
  end

  def output_message(result)
    "Coverage badge generated for #{result.command_name} to #{output_path}."
  end

  private
  
  # generates badges using ImageMagick
  def generate_badges(result)
    generate_header_badge(result)
    generate_group_badges(result)
  end
  
  def generate_header_badge(result)
    overall_cov = result.source_files.covered_percent.round(0)
    overall_strength = result.covered_strength.round(0)
    command = []
    command[0] = """
      convert -size 52x25 xc:'#{coverage_color(overall_cov)}' -pointsize 20 -font 'Helvetica-Narrow-Bold' \
      -gravity east -fill white -draw \"kerning 2 text +2,+2 '#{overall_cov}%'\" \
      -alpha set -bordercolor none -border 3 \
      -gravity North -chop 0x3 \
      -gravity South -chop 0x3 \
      -gravity West -chop 3x0 \
      #{output_path}/tmp.png
      """
    command[1] = """
      convert #{output_path}/tmp.png \\( -size 237x25 xc:'#{strength_color(overall_strength)}' \
      -pointsize 17 -fill white -font 'Helvetica' \
      -draw \"kerning 1 text 4,19 'OVERALL STRENGTH'\" \
      -gravity West \
      -background white -splice 1x0  -background black -splice 1x0 \
      -trim  +repage -gravity West -chop 1x0 -gravity East \
      -background '#{strength_color(overall_strength)}' -splice 2x0 \\) \
      -background none +append #{output_path}/tmp.png
      """
    command[2] = """
      convert #{output_path}/tmp.png -format 'roundrectangle 1,1 %[fx:w+4],%[fx:h+25] 10,10' \
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
        raise Exception unless system(cmd)
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
        convert -size 52x25 xc:'#{coverage_color(cov)}' -pointsize 20 -font 'Helvetica-Narrow-Bold' \
        -gravity east -fill white -draw \"kerning 2 text +2,+2 '#{cov}%'\" \
        -alpha set -bordercolor none -border 3 \
        -gravity North -chop 0x3 \
        -gravity South -chop 0x3 \
        -gravity East -chop 3x0 #{output_path}/tmp.png
      """
      command[1] = """
        convert #{output_path}/tmp.png \\( -size 300x25 xc:transparent \
        -pointsize 17 -fill '#{strength_color(strength)}' -font 'Helvetica-Bold' \
        -draw \"kerning 0.5 text 4,19 '#{name.upcase}'\" \
        -gravity West -background white -splice 1x0 -background black -splice 1x0 \
        -trim  +repage -gravity West -chop 1x0 -gravity East \
        -background none -splice 2x0 \
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
          raise Exception unless system(cmd)
        end
      ensure
        system("rm #{output_path}/tmp.png")
      end
    end
    timestamp_cmd = """
      convert #{output_path}/coverage-badge.png -alpha set -bordercolor none -border 3 \
      -gravity North -chop 0x3 \
      -gravity East -chop 3x0 \
      -gravity West -chop 3x0 \\( -background none -font 'Helvetica' label:'Generated #{Time.current.strftime('%m-%d-%y %H:%M UTC')}' \\) -background none -gravity center -append #{output_path}/coverage-badge.png
    """
    raise Exception unless system(timestamp_cmd)
  end

  def output_path
    SimpleCov.coverage_path
  end

  def coverage_color(covered_percent)
    if covered_percent > 90
      '#4fb151'
    elsif covered_percent > 80
      '#ded443'
    else
      '#a23e3f'
    end
  end

  def strength_color(covered_strength)
    if covered_strength > 1
      '#4fb151'
    elsif covered_strength == 1
      '#ded443'
    else
      '#4fb151'
    end
  end
  
  def timeago(time)
    "<abbr class=\"timeago\" title=\"#{time.iso8601}\">#{time.iso8601}</abbr>"
  end

end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
require 'simplecov-badge/version'
