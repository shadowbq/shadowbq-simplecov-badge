require 'spec_helper'

describe SimpleCov::Formatter::BadgeFormatter do
  before(:all) do
    @obj = SimpleCov::Formatter::BadgeFormatter.new
  end

  describe 'format' do    
    it "handles a StandardError" do
      result = double("result")
      result.stub(:command_name) {'test'}
      @obj.stub(:check_imagemagick).and_raise(ImageMagickError, "test phrase")
      @obj.should_not_receive(:generate_header_badge)
      @obj.should_not_receive(:generate_group_badges)
      $stdout.should_receive(:write).at_least(:once)
      @obj.format(result)
    end
  end

  describe "options" do  
    it 'generates option getter/setters' do
      SimpleCov::Formatter::BadgeFormatter.generate_groups.should eq(true)
      SimpleCov::Formatter::BadgeFormatter.generate_groups = false
      SimpleCov::Formatter::BadgeFormatter.generate_groups.should eq(false)
      SimpleCov::Formatter::BadgeFormatter.timestamp.should eq(false)
      SimpleCov::Formatter::BadgeFormatter.timestamp = true
      SimpleCov::Formatter::BadgeFormatter.timestamp.should eq(true)
    end
  end
  
  describe "badge generation" do
    it 'should generate header badge' do
      @obj.stub(:check_imagemagick).and_return(0)
      @obj.stub(:generate_group_badges).and_return(0)
      @obj.stub(:coverage_color).and_return('green')
      @obj.stub(:strength_color).and_return(@obj.class.green)
      @obj.stub(:strength_foreground).and_return('white')
      @obj.stub(:strength_background).and_return(@obj.class.green)
      @obj.stub(:title_foreground).and_return('white')
      @obj.stub(:title_background).and_return(@obj.class.green)
      @obj.stub(:output_path).and_return('.')
      result = double('Result')
      result.stub_chain('source_files.covered_percent').and_return(50)
      result.stub('covered_strength').and_return(90)
      result.stub(:command_name) {'test'}
      @obj.format(result)
      $?.success?.should eq(true)
      File.size('coverage-badge.png')
    end
 
    it 'should generate group badges' do
      SimpleCov::Formatter::BadgeFormatter.generate_groups = true
      result = double('Result')
      result.stub(:command_name) {'test'}
      files = double("files")
      files.stub('covered_percent').and_return(50)
      files.stub('covered_strength').and_return(90)
      groups = {'group1' => files, 'group2' => files}
      result.stub_chain('groups').and_return(groups)
      @obj.stub(:check_imagemagick).and_return(0)
      @obj.stub(:generate_header_badge).and_return(0)
      @obj.stub(:coverage_color).and_return('green')
      @obj.stub(:strength_color).and_return('green')
      @obj.stub(:strength_foreground).and_return('white')
      @obj.stub(:strength_background).and_return(@obj.class.green)
      @obj.stub(:title_foreground).and_return('white')
      @obj.stub(:title_background).and_return(@obj.class.green)
      @obj.stub(:output_path).and_return('.')
      expect{ @obj.format(result) }.to change{File.size('coverage-badge.png')}
      $?.success?.should eq(true)
    end

    describe 'generation helpers' do
      # Calling all these private methods here is a little ugly; but it seemed like the
      # right thing in this case - testing these through public methods (format) just
      # isn't possible
     describe 'title_background' do
        it 'returns transparent if foreground and lowest color if not' do
          @obj.instance_eval{title_background(60, 1, true, true)}.should eq('transparent')
          @obj.instance_eval{title_background(91,1.1, false, true)}.should eq(@obj.class.green)
          @obj.instance_eval{title_background(91,1, false, true)}.should eq(@obj.class.yellow)
          @obj.instance_eval{title_background(65,1, false, true)}.should eq(@obj.class.red)
          @obj.instance_eval{title_background(90,1, false, false)}.should eq('silver')
        end
      end

      describe 'title_foreground' do
        it 'returns white unless foreground and lowest color otherwise' do
          @obj.instance_eval{title_foreground(60,2,false, true)}.should eq('white')
          @obj.instance_eval{title_foreground(91,2,true, true)}.should eq(@obj.class.green)
          @obj.instance_eval{title_foreground(85,2,true, true)}.should eq(@obj.class.yellow)
          @obj.instance_eval{title_foreground(85,0.5,true, true)}.should eq(@obj.class.red)
          @obj.instance_eval{title_foreground(90,1, false, false)}.should eq('white')
        end
      end
        
      describe 'strength_background' do
        it 'returns transparent if foreground and strength_color if not' do
          @obj.instance_eval{strength_background(60, true)}.should eq('transparent')
          @obj.class.any_instance.should_receive(:strength_color)
          @obj.instance_eval{strength_background(60, false)}
        end
      end

      describe 'strength_foreground' do
        it 'returns strength color if foreground and white if not' do
          @obj.instance_eval{strength_foreground(60,false)}.should eq('white')
          @obj.class.any_instance.should_receive(:strength_color)
          @obj.instance_eval{strength_foreground(60,true)}
        end
      end

      describe 'coverage_color' do
        it 'returns the correct colors' do
          @obj.instance_eval{coverage_color(91)}.should eq(@obj.class.green)
          @obj.instance_eval{coverage_color(81)}.should eq(@obj.class.yellow)
          @obj.instance_eval{coverage_color(60)}.should eq(@obj.class.red)
        end
      end

      describe 'strength_color' do
        it 'returns the correct colors' do
          @obj.instance_eval{strength_color(1.1)}.should eq(@obj.class.green)
          @obj.instance_eval{strength_color(1)}.should eq(@obj.class.yellow)
          @obj.instance_eval{strength_color(0.9)}.should eq(@obj.class.red)
        end
      end
    end
    
    after(:all) do
      `rm coverage-badge.png`
    end
  end
  

end
