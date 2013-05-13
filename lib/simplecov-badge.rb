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
    "Coverage report generated for #{result.command_name} to #{output_path}. #{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered."
  end

  private
  
  # generates badges using ImageMagick
  def generate_badges(result)
    overall_cov = result.source_files.covered_percent.round(0)
    overall_strength = result.covered_strength.round(0)
    command = "convert -size 300x30 xc:#{coverage_css_class(overall_cov)} \
              -draw \"fill silver rectangle 47,0 300,30\" -strokewidth 2 \
              -draw \"stroke white line 47,0 47,30\" -pointsize 22 -font 'Helvetica-Narrow-Bold' \
              -fill white -draw \"kerning 2 text 3,22 '#{overall_cov}%'\" -pointsize 19 -fill white \
              -font 'Helvetica' -draw \"kerning 1 text 51,22 'CODE COVERAGE'\" \
              -gravity West -background white -splice 1x0  -background black -splice 1x0 \
              -trim  +repage -gravity West -chop 1x0 -gravity East \
              -background silver -splice 2x0 \
              -format 'roundrectangle 1,1 %[fx:w+10],%[fx:h+4] 10,10' -write info:tmp.mvg \
              -alpha set -bordercolor none -border 3 \\( +clone -alpha transparent \
              -background none -fill white -stroke none -strokewidth 0 -draw @tmp.mvg \\) \
              -compose DstIn -composite #{output_path}/coverage-badge.png"
    if system(command)
      system('rm tmp.mvg')
    else
      return false
    end
    result.groups.each do |name, files|
      cov = result.source_files.covered_percent.round(0)
      strength = result.covered_strength.round(0)
      command = """
        convert #{output_path}/coverage-badge.png \\( -size 300x30 xc:#{coverage_css_class(cov)} -draw 'fill silver rectangle 47,0 300,30' \
        -strokewidth 2 -draw 'stroke white line 47,0 47,30' \
        -pointsize 22 -font 'Helvetica-Narrow-Bold' \
        -fill white -draw \"kerning 2 text 3,22 '#{cov}%'\" \
        -pointsize 19 -fill white -font 'Helvetica' \
        -draw \"kerning 0.5 text 51,22 '#{name.upcase}'\" \
        -gravity West -background white -splice 1x0  -background black -splice 1x0 \
        -trim  +repage -gravity West -chop 1x0 -gravity East \
        -background silver -splice 2x0 \
        -format 'roundrectangle 1,1 %[fx:w+10],%[fx:h+4] 10,10' \
        -write info:tmp.mvg \
        -alpha set -bordercolor none -border 3 \
        \\( +clone -alpha transparent -background none \
           -fill white -stroke none -strokewidth 0 -draw @tmp.mvg \\) \
        -compose DstIn -composite \\) -gravity West -background none -append #{output_path}/coverage-badge.png
        """
        if system(command)
          system('rm tmp.mvg')
        else
          return false
        end
    end
  end

  def output_path
    SimpleCov.coverage_path
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
  
  def timeago(time)
    "<abbr class=\"timeago\" title=\"#{time.iso8601}\">#{time.iso8601}</abbr>"
  end

end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
require 'simplecov-badge/version'
