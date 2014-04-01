# Aruba extensions to get rid of https://github.com/cucumber/aruba/issues/182

When /^I run command `([^`]*)`$/ do |cmd|
  # Pass the command as is, pay attention
  # stderr is joined with stdout
  @last_output = `#{cmd} 2>&1`
end

Then /^the output from last command should contain "([^"]*)"$/ do |expected|
  @last_output.should include(expected)
end
