namespace MovieHotflix
{
    public partial class MovieDetailsForm : Form
    {
        private int movieId;
        private List<Movie> similarMovies = new List<Movie>();

        public MovieDetailsForm(int id)
        {
            InitializeComponent();
            movieId = id;
            Load += MovieDetailsForm_Load;
            similarMoviesListBox.DoubleClick += similarMoviesListBox_DoubleClick;
        }

        private async void MovieDetailsForm_Load(object sender, EventArgs e)
        {
            try
            {
                Movie movie = await MovieApi.GetMovieById(movieId);
                titleLabel.Text = movie.title;
                overviewTextBox.Text = movie.overview;
                string year = "Unknown";

                if (!string.IsNullOrEmpty(movie.release_date))
                {
                    year = movie.release_date.Substring(0, Math.Min(4, movie.release_date.Length));
                }

                yearLabel.Text = "Year: " + year;
                string genreNames = "";

                foreach (Genre genre in movie.genres)
                {
                    if (genreNames != "")
                    {
                        genreNames += ", ";
                    }
                    genreNames += genre.name;
                }

                genreLabel.Text = "Genres: " + genreNames;

                if (!string.IsNullOrEmpty(movie.poster_path))
                {
                    posterPictureBox.LoadAsync("https://image.tmdb.org/t/p/w500" + movie.poster_path);
                }

                Movies result = await MovieApi.GetSimilarMovies(movieId);

                similarMoviesListBox.Items.Clear();
                similarMovies = new List<Movie>();

                if (result.Results != null)
                {
                    int count = Math.Min(5, result.Results.Count);

                    for (int i = 0; i < count; i++)
                    {
                        Movie similarMovie = result.Results[i];
                        similarMovies.Add(similarMovie);
                        similarMoviesListBox.Items.Add(similarMovie.title + " (" + similarMovie.release_date + ")");
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error");
            }
        }

        private void similarMoviesListBox_DoubleClick(object sender, EventArgs e)
        {
            if (similarMoviesListBox.SelectedIndex >= 0)
            {
                Movie selectedMovie = similarMovies[similarMoviesListBox.SelectedIndex];
                MovieDetailsForm detailsForm = new MovieDetailsForm(selectedMovie.id);
                detailsForm.ShowDialog();
            }
        }
    }
}