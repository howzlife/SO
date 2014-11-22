class MailChimp
	#uses mailchimp-api-ruby https://bitbucket.org/mailchimp/mailchimp-api-ruby/
	@mc = nil
	@mak = nil
	@mli = nil

	#initialize necessary mailchimp keys and the mailchimp object
	def initialize(mailchimp_api_key, mailchimp_list_id)
		@mak = mailchimp_api_key
		@mli = mailchimp_list_id
		@mc = Mailchimp::API.new(mailchimp_api_key)
	end

	#add user to mailchimp list with no opt in
	def addmember(user)
		#generate random leid for mailchimp
		user.euid = rand(1 .. 500000000).to_s
		user.save
		#assuming LEID is our user id and EUID is mailchimp's unique one
		#taken from here https://bitbucket.org/mailchimp/mailchimp-api-ruby/
		subscribers = [{ "EMAIL" => { "email" => user.email,
                 "LEID" => user.id.to_s,
                 "EUID" => user.euid
               },

               :EMAIL_TYPE => 'html',
               :merge_vars => { "FNAME" => user.first_name,
                                "LNAME"  => user.last_name,
                                "STATUS"    => "Subscribed"
                              }
              }]

        #batch-subscribe(string apikey, string id, array batch, boolean double_optin, boolean update_existing, boolean replace_interests)
      	@mc.lists.batch_subscribe(@mli, subscribers, false, true, false)
	end
end
