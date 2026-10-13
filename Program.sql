 static async Task Main()
    {
        var allGenres = await MovieApi.GetGenreList();
        var allMovies = await MovieApi.GetPopularMovies(page: 1);
        var allMoviesByName = await MovieApi.GetMoviesByName("Star wars", page: 1);
        var allMoviesByGenre = await MovieApi.GetMoviesByGenre(allGenres.genres[0].id, page: 1);
        var allMoviesByNameAndYear = MovieApi.GetMoviesByYearAndName("Star Wars", 2001);
        var currentMovie = await MovieApi.GetMovieById(allMoviesByGenre.Results[0].id);
        var similarMovies = await MovieApi.GetSimilarMovies(allMoviesByGenre.Results[0].id, page:1);
    }
