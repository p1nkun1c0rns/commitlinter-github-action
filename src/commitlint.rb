#!/usr/bin/env ruby
# frozen_string_literal: true

require 'git'
require 'pp'

lint_err_count = 0
default_message = 'Your commit does not match the required style!'

workingdir              = ENV.fetch('INPUT_WORKINGDIR', '.')
basebranch              = ENV.fetch('INPUT_BASEBRANCH', 'master')
author_name_regex       = ENV.fetch('INPUT_AUTHOR_NAME_REGEX', '')
author_name_message     = ENV.fetch('INPUT_AUTHOR_NAME_MESSAGE', default_message)
author_email_regex      = ENV.fetch('INPUT_AUTHOR_EMAIL_REGEX', '')
author_email_message    = ENV.fetch('INPUT_AUTHOR_EMAIL_MESSAGE', default_message)
committer_name_regex    = ENV.fetch('INPUT_COMMITTER_NAME_REGEX', '')
committer_name_message  = ENV.fetch('INPUT_COMMITTER_NAME_MESSAGE', default_message)
committer_email_regex   = ENV.fetch('INPUT_COMMITTER_EMAIL_REGEX', '')
committer_email_message = ENV.fetch('INPUT_COMMITTER_EMAIL_MESSAGE', default_message)
commit_message_regex    = ENV.fetch('INPUT_COMMIT_MESSAGE_REGEX', '')
commit_message_message  = ENV.fetch('INPUT_COMMIT_MESSAGE_MESSAGE', default_message)

g = Git.open(workingdir)

# get all commits
commits = g.log

commits.each do |commit|
  puts "🛠  linting commit #{commit.sha} ..."

  # switch case?
  unless commit.author.name.match(/#{author_name_regex}/)
    puts author_name_message unless author_name_message.empty?
    puts "author name '#{commit.author.name}' dont match regex '#{author_name_regex}'"
    lint_err_count += 1
  end

  unless commit.author.email.match(/#{author_email_regex}/)
    puts author_email_message unless author_email_message.empty?
    puts "author email '#{commit.author.email}' dont match regex '#{author_email_regex}'"
    lint_err_count += 1
  end

  unless commit.committer.name.match(/#{committer_name_regex}/)
    puts committer_name_message unless committer_name_message.empty?
    puts "committer name '#{commit.committer.name}' dont match regex '#{committer_name_regex}'"
    lint_err_count += 1
  end

  unless commit.committer.email.match(/#{committer_email_regex}/)
    puts committer_email_message unless committer_email_message.empty?
    puts "commiter email '#{commit.committer.email}' dont match regex '#{committer_email_regex}'"
    lint_err_count += 1
  end

  unless commit.message.match(/#{commit_message_regex}/)
    puts commit_message_message unless commit_message_message.empty?
    puts "commit message '#{commit.message}' dont match regex '#{commit_message_regex}'"
    lint_err_count += 1
  end
end

if lint_err_count.positive?
  puts "found #{lint_err_count} lint issues 😒 💩"
  exit(1)
else
  puts "found #{lint_err_count} lint issues 🙌 🎉"
  exit(0)
end
