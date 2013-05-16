# Badge formatter for SimpleCov
[ ![Codeship Status for matthew342/simplecov-badge](https://www.codeship.io/projects/c46ee0e0-9da1-0130-7a9e-0e0ae47480c0/status?branch=master)](https://www.codeship.io/projects/3367)
[ ![Code Coverage for matthew342/simplecov-badge](http://matthew342.github.io/simplecov-badge/coverage/coverage-badge.png)](http://matthew342.github.io/simplecov-badge/coverage/index.html)

Generates coverage badges from SimpleCov using ImageMagick.  Great for small private repos that don't want to pay for a [hosted service](https://coveralls.io/).

***Note: To learn more about SimpleCov, check out the main repo at https://github.com/colszowka/simplecov***

## Examples
The left side of the badge shows and is color-coded for the percentage of lines covered.  The right side is color-coded for the strength of coverage (in terms of hits/line).
####Simple
----------
![Code Coverage for matthew342/simplecov-badge](http://matthew342.github.io/simplecov-badge/coverage/coverage-badge.png)
####Including Group sub-badges and timestamp
----------
![Code Coverage for matthew342/simplecov-badge](http://matthew342.github.io/simplecov-badge/coverage-badge-example.png)

## Installation
	# In your gemfile
	gem 'simplecov-badge', :require => false
	
## Usage
	# Wherever your SimpleCov.start block is (spec_helper.rb, test_helper.rb, or .simplecov)
    SimpleCov.start 'rails' do
    	require 'simplecov-badge'
		# add your normal SimpleCov configs
  		add_filter "/app/admin/"
		# configure any options you want for SimpleCov::Formatter::BadgeFormatter
		SimpleCov::Formatter::BadgeFormatter.generate_groups = true
		SimpleCov::Formatter::BadgeFormatter.strength_foreground = true
		SimpleCov::Formatter::BadgeFormatter.timestamp = true
		# call SimpleCov::Formatter::BadgeFormatter after the normal HTMLFormatter
		SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
			SimpleCov::Formatter::HTMLFormatter,
			SimpleCov::Formatter::BadgeFormatter,
		]
	end

## Use with your CI
Your badge will be generated in the /coverage directory of your project folder.  From there, you can push it wherever you like.  Two common options are to push to S3 or to push to GitHub Pages.

####If you want to store your coverage reports in GitHub Pages
--------
You can do something like this as the last step in your build/deploy (assuming you've already created an orphan gh-pages branch):

    mkdir ../tmp-coverage
	cp -r coverage/ ../tmp-coverage/
	git config --global user.email "CI@example.com"
	git config --global user.name "CI Server"
	git checkout gh-pages
	cp -r ../tmp-coverage/ .
	rm -r ../tmp-coverage
	git add .
	git commit -a -m "CI: Coverage for $COMMIT_ID"
	git push origin gh-pages:gh-pages

REMEMBER Gitub Pages are public - so if your repo is private pushing somewhere else might be a better idea.

####If you want to store your coverage reports in S3
--------
Use one of the S3 wrappers for your language to automate pushing the files into an access-controlled S3 bucket.  I use the [S3 gem](https://github.com/qoobaa/s3).

## Options
Set these in your SimpleCov.start block - see Usage section.
<table>
	<tr>
		<td>Name</td>
		<td>Description</td>
		<td>Default</td>
	</tr>
	<tr><td>strength_indicator_title</td><td>Title for right portion of badge, which can be colored according to coverage strength (i.e. >1 hits/line = green, == 1 hits/line = yellow, <1 hits/line = red)</td><td> 'TEST COVERAGE'</td></tr>
	<tr><td>generate_groups </td><td>Whether to generate sub-badges for each group under the main badge</td><td>true</td></tr>
	<tr><td>timestamp </td><td>Stick a timestamp on the bottom of the badge</td><td> false</td></tr>
	<tr><td>green </td><td>The specific color to be used for 'green'</td><td> '#4fb151'</td></tr>
	<tr><td>yellow </td><td>The specific color to be used for 'yellow'</td><td> '#ded443'</td></tr>
	<tr><td>red </td><td>The specific color to be used for 'red'</td><td> '#a23e3f'</td></tr>
	<tr><td>number_font </td><td>The font to use for the coverage percentage (for the main badge)</td><td> 'Helvetica-Narrow-Bold'</td></tr>
<tr><td>number_font_size </td><td>Size of font to use for the coverage percentage (for the main badge)</td><td> 20</td></tr>
<tr><td>name_font </td><td>The font to use for the name portion of the badge (of the main badge)</td><td> 'Helvetica'</td></tr>
<tr><td>name_font_size </td><td>Size of font to use for the name portion (of the main badge)</td><td> 17</td></tr>
<tr><td>badge_height </td><td>Height of the badge</td><td> 25</td></tr>
<tr><td>use_strength_color </td><td>Whether to color-code the name portion of the badge according to the coverage strength (NOT the covered percentage)</td><td> true</td></tr>
<tr><td>strength_foreground </td><td>Whether to color the foreground instead of the background when coloring the name portion of the badge according to the coverage strength</td><td> false</td></tr>
<tr><td>group_number_font </td><td>Same as above, but for group sub-badges</td><td> 'Helvetica-Narrow-Bold'</td></tr>
<tr><td>group_number_font_size </td><td>Same as above, but for group sub-badges</td><td> 20</td></tr>
<tr><td>group_name_font </td><td>Same as above, but for group sub-badges</td><td> 'Helvetica-Bold'</td></tr>
<tr><td>group_name_font_size </td><td>Same as above, but for group sub-badges</td><td> 17</td></tr>
<tr><td>group_badge_height </td><td>Same as above, but for group sub-badges</td><td> 25</td></tr>
<tr><td>use_strength_color_for_group_name </td><td>Same as above, but for group sub-badges</td><td> true</td></tr> 
<tr><td>group_strength_foreground </td><td>Same as above, but for group sub-badges</td><td> true</td></tr>
</table>

#### Note on Patches/Pull Requests

Pull requests are much appreciated - but please add tests!
Run the test suite by cloning down the repo, then:

    bundle install
    rspec


Copyright
---------
Adapted from [simplecov-html](https://github.com/colszowka/simplecov-html).  
Thanks to [Christoph Olszowka](https://github.com/colszowka).
Copyright (c) 2013 Matt Hale. See LICENSE for details.
