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
    #@movies = Movie.all
    @movies = Movie.scoped    # instead of all: in rails 3 all returns array.
    @all_ratings = Movie.ALL_RATINGS
    @ratings_filter_arr = Movie.ALL_RATINGS

    params_updated = false;

    logger.info params

    #--------------------------------------------------------------
    #Maintain ReSTful URL: move parameters from session to params if missing
 
    tempparams = {}

    raitingsUpdate = false
    tempparams[:ratings] = params[:ratings]
    if (params[:ratings] == nil)
      tempparams[:ratings] = session[:ratings] 
      raitingsUpdate = true
    end

    orderUpdate = false
    tempparams[:order] = params[:order] 
    if (params[:order] == nil)
      tempparams[:order] = session[:order] 
      orderUpdate = true
    end

    if(orderUpdate || raitingsUpdate)
      redirect_to movies_path(tempparams)  if ! tempparams
    end
    #--------------------------------------------------------------

    if(params[:order])
      session[:order] = params[:order]
    end

    params[:order] = session[:order]
    @order = params[:order]
    if(@order == "title")
      @movies = Movie.order("LOWER(#{@order})")
    elsif(@order == "release_date")
      @movies = Movie.order("#{@order}")
    end

    #debugger
    if(params[:ratings])
      session[:ratings] = params[:ratings]
    end

      params[:ratings] = session[:ratings]
      if(params[:ratings] != nil) 
      @ratings_filter_arr = params[:ratings].keys
      @movies = @movies.where("rating in (?)", @ratings_filter_arr) #if params[:ratings]
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
