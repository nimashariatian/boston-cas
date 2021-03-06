###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ImmediateMailer < ApplicationMailer

  def immediate
    to = params[:to]
    @message = params[:message]
    mail to: to, subject: "#{prefix} #{@message.subject}"
  end

end
