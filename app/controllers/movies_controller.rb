class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

# All the requiremens are supposed to write in index
  def index
    @all_ratings = Movie.all_ratings

    # Get the remembered settings
    if (params[:filter] == nil and params[:ratings] == nil and params[:sort] == nil and 
              (session[:filter] != nil or session[:ratings] != nil or session[:sort] != nil))
      if (params[:filter] == nil and session[:filter] != nil)
        params[:filter] = session[:filter]
      end
      if (params[:sort] == nil and session[:sort] != nil)
        params[:sort] = session[:sort]
      end
      redirect_to movies_path(:filter => params[:filter], :sort => params[:sort], :ratings => params[:ratings]) 
    else

      if (params[:filter] != nil and params[:filter] != "[]")
        @filtered_ratings = params[:filter].scan(/[\w-]+/)
        session[:filter] = params[:filter]
      else
        @filtered_ratings = params[:ratings] ? params[:ratings].keys : []
        session[:filter] = params[:ratings] ? params[:ratings].keys.to_s : nil
      end
      
      session[:sort] = params[:sort]
      session[:ratings] = params[:ratings]
      if (params[:sort] == "title") # Sort by titles
        if (params[:ratings] or params[:filter]) # filter ratings
          @movies = Movie.find(:all, :conditions => {:rating => (@filtered_ratings==[] ? @all_ratings : @filtered_ratings)}, :order => "title")
        else
          @movies = Movie.find(:all, :order => "title")
        end
      elsif (params[:sort] == "release_date") # Sort by release_date
        if (params[:ratings] or params[:filter]) # filter ratings
          @movies = Movie.find(:all, :conditions => {:rating => (@filtered_ratings==[] ? @all_ratings : @filtered_ratings)}, :order => "release_date")
        else
          @movies = Movie.find(:all, :order => "release_date")
        end
      elsif (params[:sort] == nil)
        if (params[:ratings] or params[:filter]) # filter ratings
          @movies = Movie.find(:all, :conditions => {:rating => (@filtered_ratings==[] ? @all_ratings : @filtered_ratings)})
        else
          @movies = Movie.all
        end
      end
    end
  end
          

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
