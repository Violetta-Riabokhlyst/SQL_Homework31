namespace MovieHotflix
{
    public partial class CiteDesign : Form
    {
        private List<Movie> movies = new List<Movie>();
        private List<Genre> genres = new List<Genre>();

        private int currentPage = 1;
        private int totalPages = 1;
        private int selectedGenre = 0;
        private string searchName = "";
        private bool ignoreGenreChange = false;

        public CiteDesign()
        {
            InitializeComponent();

            Load += CiteDesign_Load;
            searchButton.Click += searchButton_Click;
            genreComboBox.SelectedIndexChanged += genreComboBox_SelectedIndexChanged;
            previousButton.Click += previousButton_Click;
            nextButton.Click += nextButton_Click;
            moviesListBox.DoubleClick += moviesListBox_DoubleClick;
        }

        private async void CiteDesign_Load(object sender, EventArgs e)
        {
            try
            {
                Genres result = await MovieApi.GetGenreList();
                genres = result.genres;

                genreComboBox.Items.Clear();
                genreComboBox.Items.Add("All genres");

                foreach (Genre genre in genres)
                {
                    genreComboBox.Items.Add(genre.name);
                }

                ignoreGenreChange = true;
                genreComboBox.SelectedIndex = 0;
                ignoreGenreChange = false;

                await loadMovies();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error");
            }
        }

        private async Task loadMovies()
        {
            try
            {
                Movies result;

                if (searchName != "")
                {
                    result = await MovieApi.GetMoviesByName(searchName, currentPage);
                }
                else if (selectedGenre != 0)
                {
                    result = await MovieApi.GetMoviesByGenre(selectedGenre, currentPage);
                }
                else
                {
                    result = await MovieApi.GetPopularMovies(currentPage);
                }

                movies = result.Results;

                if (movies == null)
                {
                    movies = new List<Movie>();
                }

                totalPages = result.Total_Pages;

                if (totalPages > 500)
                {
                    totalPages = 500;
                }

                moviesListBox.Items.Clear();

                foreach (Movie movie in movies)
                {
                    string year = "Unknown";

                    if (!string.IsNullOrEmpty(movie.release_date))
                    {
                        year = movie.release_date.Substring(0, Math.Min(4, movie.release_date.Length));
                    }
                    moviesListBox.Items.Add(movie.title + " (" + year + ")" + " - Rating: " + movie.vote_average);
                }

                pageLabel.Text = currentPage + " / " + totalPages;

                previousButton.Enabled = currentPage > 1;
                nextButton.Enabled = currentPage < totalPages;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error");
            }
        }

        private async void searchButton_Click(object sender, EventArgs e)
        {
            searchName = searchTextBox.Text.Trim();
            currentPage = 1;
            selectedGenre = 0;
            ignoreGenreChange = true;
            genreComboBox.SelectedIndex = 0;
            ignoreGenreChange = false;
            await loadMovies();
        }

        private async void genreComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ignoreGenreChange)
            {
                return;
            }

            if (genreComboBox.SelectedIndex < 0)
            {
                return;
            }

            searchTextBox.Text = "";
            searchName = "";
            currentPage = 1;

            if (genreComboBox.SelectedIndex == 0)
            {
                selectedGenre = 0;
            }
            else
            {
                selectedGenre =
                    genres[genreComboBox.SelectedIndex - 1].id;
            }

            await loadMovies();
        }

        private async void previousButton_Click(object sender, EventArgs e)
        {
            if (currentPage > 1)
            {
                currentPage--;
                await loadMovies();
            }
        }

        private async void nextButton_Click(object sender, EventArgs e)
        {
            if (currentPage < totalPages)
            {
                currentPage++;
                await loadMovies();
            }
        }

        private void moviesListBox_DoubleClick(object sender, EventArgs e)
        {
            if (moviesListBox.SelectedIndex >= 0)
            {
                Movie selectedMovie = movies[moviesListBox.SelectedIndex];
                MovieDetailsForm detailsForm = new MovieDetailsForm(selectedMovie.id);
                detailsForm.ShowDialog();
            }
        }
    }
}