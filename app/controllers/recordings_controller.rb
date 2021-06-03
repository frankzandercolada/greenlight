# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>

class RecordingsController < ApplicationController
  before_action :find_room
  before_action :verify_room_ownership
  require( Rails.root.join('bbb-events', 'bbbevents.rb'))

  META_LISTED = "gl-listed"
  def recorded_list
    path = "public/#{params[:record_id]}/events.xml"
    clear_file(params[:record_id])
    get_file_via_shh(params[:record_id])
    if File.exist?(path)
      @recording = BBBEvents.parse(path)
      @data = @recording.to_h
    else
      redirect_to root_url
    end
  end
  def recorded_list_download
    path = "public/#{params[:record_id]}/events.xml"
    clear_file(params[:record_id])
    get_file_via_shh(params[:record_id]) 
    if File.exist?(path)   
      recording = BBBEvents.parse(path)
      recording.create_csv(Rails.root.join('public', 'data.csv'))
      send_file(Rails.root.join('public', 'data.csv'))
    else
      redirect_to root_url
    end
  end

  # POST /:meetingID/:record_id
  def update
    meta = {
      "meta_#{META_LISTED}" => (params[:state] == "public"),
    }

    res = update_recording(params[:record_id], meta)

    # Redirects to the page that made the initial request
    redirect_back fallback_location: root_path if res[:updated]
  end

  # PATCH /:meetingID/:record_id
  def rename
    update_recording(params[:record_id], "meta_name" => params[:record_name])

    redirect_back fallback_location: room_path(@room)
  end

  # DELETE /:meetingID/:record_id
  def delete
    delete_recording(params[:record_id])

    # Redirects to the page that made the initial request
    redirect_back fallback_location: root_path
  end

  private

  def find_room
    @room = Room.find_by!(bbb_id: params[:meetingID])
  end

  # Ensure the user is logged into the room they are accessing.
  def verify_room_ownership
    redirect_to root_path if !@room.owned_by?(current_user) && !current_user&.role&.get_permission("can_manage_rooms_recordings")
  end

  def get_file_via_shh(record_id)
      require Rails.root.join('net', 'ssh.rb')
      require Rails.root.join('net', 'sftp.rb')
      logger.error "no no no ++++ no no #{ ENV['SERVER_PASSWORD']}"

      Net::SFTP.start('34.65.0.25', 'stats', :password => 'd9oOdgwjR3%5HE8v') do |sftp|
        directory_name = "public/#{record_id}"
        Dir.mkdir(directory_name) unless File.exists?(directory_name)
        begin
          sftp.download!("/var/bigbluebutton/recording/raw/#{record_id}/events.xml" ,"public/#{record_id}/events.xml")
        rescue 
          
        end
      end  
  end 

  def clear_file(record_id)
    File.delete("public/#{record_id}/events.xml") if File.exist?("public/#{record_id}/events.xml")
  end

end
