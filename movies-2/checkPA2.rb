class MovieData

	def initialize(*args)
		h1={:u1 => ["u1.base","u1.test"], 
			:u2 => ["u2.base","u2.test"],
			:u3 => ["u3.base","u3.test"],
			:u4 => ["u4.base","u4.test"],
			:u5 => ["u5.base","u5.test"],
			:ua => ["ua.base","ua.test"],
			:ub => ["ub.base","ub.test"],
			}
		foldername = args[0]

		if args.length == 1
			train_filename = File.join(foldername,"u.data")
			@test_umr_arr = nil
		else
			train_test_pair = h1[args[1]]
			train_filename = File.join(foldername,train_test_pair[0])
			test_filename = File.join(foldername,train_test_pair[1])
			@test_umr_arr = load_test(test_filename)
		end

		@train_umr_h, @train_mur_h = load_train(train_filename)
	end

	def load_train(train_filename)
		train_data = open(train_filename).read
		
		umr_h = Hash.new
		mur_h = Hash.new

		train_data.each_line do |line|
			data = line.split(" ")
			user_id = data[0].to_i
			movie_id = data[1].to_i
			rate = data[2].to_i

			if !umr_h.has_key?(user_id)
				umr_h[user_id] = Hash.new
			end

			umr_h [user_id] [movie_id] = rate

			if !mur_h.has_key?(movie_id)
				mur_h[movie_id] = Hash.new
			end

			mur_h [movie_id][user_id] = rate
		end

		return umr_h, mur_h
	end

	def load_test(test_filename)
		test_data = open(test_filename).read
		umr_arr = Array.new
		test_data.each_line do |line|
			data=line.split(" ")
			user_id=data[0].to_i
			movie_id=data[1].to_i
			rate=data[2].to_i
			umr_arr.push([user_id, movie_id, rate])
		end
		return umr_arr
	end

	def rating(u,m) 

		if @train_umr_h.has_key?(u) && @train_umr_h[u].has_key?(m) 
				return @train_umr_h[u][m]
		else
			return 0
		end

	end


	def movies(u)

		if @train_umr_h.has_key?(u)
			return @train_umr_h[u].keys
		else
			return 0
		end

	end


	def viewers(m)

		if @train_mur_h.has_key?(m)
			return @train_mur_h[m].keys
		else
			return 0
		end

	end


	def predict(u,m)
		hash=Hash.new
		
		if viewers(m)==0
			return 0
		else
			ten_viewers=Array.new(viewers(m)[0..10])

			ten_viewers.each do |user|
			
				if user!=u
					num_common_movies=(movies(u)[0..19] & movies(user)[0..19]).length
					hash[num_common_movies]=user
				end

			end 

		#finds the user out of the ten viewers who has the maximum number of movies watched in common with our user u and returns the rating that user gave to movie m
			return rating(hash[hash.keys.max],m)
		end

	end

	
	def run_test(*args)

		if args.length == 1
			k = args[0]
			ratinglist=Array.new(@test_umr_arr[0...k])
		else
			ratinglist=Array.new(@test_umr_arr)
		end

		ratinglist.each do |line|		
  				predicted= predict(line[0],line[1])
				line.push(predicted)
  		end

  		return MovieTest.new(ratinglist)
	end

end


class MovieTest

	# takes ratinglist i.e. an array of arrays with each element in the form [user_id, movie_id, rating, predicted rating]
	# @error is an array whoese elements are the difference between predicted rating and actual rating for each element on the ratinglist 
	def initialize(ratinglist)
		@ratinglist=ratinglist
		@error=find_error
		@length=ratinglist.length
	end	

	# this method goes through each element of the rating list i.e. each array and finds the difference between the actual and 
	# predicted rating for each and stores the value in an array and returns it
	def find_error
		error=[]
			@ratinglist.each do |result|
				error.push((result[2]-result[3]).abs)
			end
		return error
	end	


	# this method returns the average predication error
	def mean
		summ = @error.inject(0) {|sum, i|  sum + i }
		return (summ.to_f/@length)
	end

	# this method returns the standard deviation of the error
	def stddev
		mean_ = mean
		sum=0
		@error.each do |error|
			sum += ((error - mean_ ) ** 2)
		end

		return Math.sqrt(sum.to_f/@length)
	end

	# this method returns the root mean square error of the prediction
	def rms
		mean_ = mean
		sum=0
		@error.each do |error|
			sum += ((error - mean_ ) ** 2)
		end

		return Math.sqrt(sum.to_f/@length)
	end

	# this method returns an array of the predictions in the form [u,m,r,p].
	def to_a
		print @ratinglist
		puts
	end
			

end





obj=MovieData.new("ml-100k", :u2)

#puts obj.similarity(1,126)
#puts obj.most_similar(1)


#puts obj.viewers(100)

t=obj.run_test(100)
t.to_a
puts t.mean





