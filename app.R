# load packages
library(shiny)
library(readr)
library(dplyr)
library(ggplot2)

# Import dog breed data
dogs <- read_csv("dog_ratings.csv")

# I removed some breeds with welfare concerns. Sorry. In some cases they are alright, but for someone using
# a dog breed selector, they most likely won't know enough to actually locate and buy one of these dogs responsibly.
# However, I left in some breeds that have welfare concerns and are commonly found in shelters because
# I don't want to discourage their adoption, i.e. English Bulldog.
excluded_breeds <- c("Goldendoodle", "French Bulldog", "Pug")
dogs <- dogs %>%
  filter(!name %in% excluded_breeds)

# Prepare data
dogs <- dogs %>%
  mutate(avg_weight = (min_weight + max_weight) / 2,
    dog_size = case_when(
      is.na(avg_weight) ~ "Unknown",
      avg_weight < 25 ~ "Small",
      avg_weight <= 60 ~ "Medium",
      avg_weight > 60 ~ "Large"))

ui <- fluidPage(titlePanel("Fetch my Match :)"),

# App description
p("Welcome to Fetch my Match, where you can find the right dog breed for your lifestyle."),
# User instructions
p("Answer some questions about your daily life and preferences to be matched with a breed thats right for you!"),

sidebarLayout(
  sidebarPanel(

# Question 1: Dog size preference
selectInput("size",
  "What size dog would you prefer?",
  choices = c("Any size!", "Small", "Medium", "Large")),

# Question 2: Housing situation
selectInput("home",
  "What is your housing situation?",
  choices = c("An apartment", "A house with a small yard", "A house with lots of land")),

# Question 3: Exercise time
selectInput("exercise",
  "How much daily exercise can you give your dog? (be honest)",
  choices = c("Low (under 1 hour daily)", "Moderate (1–2 hours daily)", "High (2+ hours daily)")),

# Question 4: Exercise intensity
selectInput("exercise_intensity",
  "What intensity of exercise are you willing to provide?",
  choices = c("Low - leisurely walks and gentle play",
              "Moderate - brisk walks and play",
              "High - vigorous activities like running, hiking, agility, etc.")),

# Question 5: Dog ownership experience
checkboxInput("beginner",
  "I'm a first-time dog owner",
  value = FALSE),

# Question 6: Training
selectInput("training",
  "How much time and effort are you willing to put into training?",
  choices = c(
    "Low - basic commands and occasional practice",
    "Moderate - regular training and consistent practice",
    "High - daily training and advanced activities")),

# Question 7: Grooming
selectInput("grooming",
  "How much time and effort are you willing to put into grooming?",
  choices = c(
    "Low - low-maintenance coat",
    "Moderate - I can brush my dog regularly",
    "High - I'm cool with frequent grooming")),

# Question 8: Children in the household
checkboxInput("kids",
  "I have children in my household",
  value = FALSE),

# Question 9: Health-related expense concerns
selectInput("health_concern",
  "How concerned are you about breed-related health expenses?",
  choices = c(
    "Very - I want a breed with stronger general health ratings",
    "Moderate - health is one of several important factors",
    "Less - I'm ok considering breeds with more potential health concerns")),

# Question 10: Outdoor adventures
checkboxInput("outdoor_adventures",
  "I want a dog that can join me on outdoor adventures",
  value = FALSE)),

mainPanel(

# Display the user's number one breed match
h3("Your #1 Dog Breed Match!"),
textOutput("top_match"),

# Display the top 10 matches
h3("Top 10 Matches:"), plotOutput("match_plot"))),

# Display the top 50 matches in a table
h3("Your Top 50 Dog Breed Matches"),
tableOutput("match_table"))




server <- function(input, output) {

# Calculate breed matches
matched_dogs <- reactive({

# Convert exercise duration into a numerical level
exercise_time_level <- case_when(
  startsWith(input$exercise, "Low") ~ 2,
  startsWith(input$exercise, "Moderate") ~ 4,
  startsWith(input$exercise, "High") ~ 5)

# Convert exercise intensity into a numerical level
exercise_intensity_level <- case_when(
  startsWith(input$exercise_intensity, "Low") ~ 2,
  startsWith(input$exercise_intensity, "Moderate") ~ 4,
  startsWith(input$exercise_intensity, "High") ~ 5)

# Calculate points for each breed
dogs %>%
mutate(size_points = case_when(input$size == "Any size!" ~ 5,
dog_size == input$size ~ 5, TRUE ~ 0),

# Housing compatibility
housing_points = case_when(
  input$home == "An apartment" ~ apartment_living,
  input$home == "A house with a small yard" ~ 3,
  input$home == "A house with lots of land" ~ 3,
  TRUE ~ 0),

# Exercise duration compatibility
exercise_points = 5 - pmax(0, exercise_need - exercise_time_level),

# Exercise intensity compatibility
intensity_points = 5 - pmax(0, intensity - exercise_intensity_level),

# First-time dog ownership compatibility
beginner_points = case_when(input$beginner == TRUE ~ novice_owner, TRUE ~ 5),

# Training commitment compatibility
training_points = case_when(
  input$training == "Low - basic commands and occasional practice" ~ training_easiness,
  input$training == "Moderate - regular training and consistent practice" ~ 3 + training_easiness * 0.4,
  input$training == "High - daily training and advanced activities" ~ 5, TRUE ~ 0),

# Grooming compatibility
grooming_points = case_when(
  startsWith(input$grooming, "Low") ~ groom_easiness,
  startsWith(input$grooming, "Moderate") ~ 3 + groom_easiness * 0.4,
  startsWith(input$grooming, "High") ~ 5, TRUE ~ 0),

# Kid-friendliness compatibility
kids_points = case_when(input$kids == TRUE ~ kid_friendly, TRUE ~ 5),

# General health compatibility
health_points = case_when(
  startsWith(input$health_concern, "Very") ~ general_health,
  startsWith(input$health_concern, "Moderate") ~ 3 + general_health * 0.4,
  startsWith(input$health_concern, "Less") ~ 5, TRUE ~ 0),

# Outdoor adventure compatibility
outdoor_points = case_when(
  input$outdoor_adventures == TRUE ~ (energy + exercise_need + intensity) / 3, TRUE ~ 5)) %>%

# Handle missing ratings
mutate(across(c(size_points, housing_points, exercise_points, intensity_points,
  beginner_points, training_points, grooming_points, kids_points, health_points, outdoor_points),
        ~ coalesce(.x, 3))) %>%

# Overall match score
mutate(match_score = size_points + housing_points + exercise_points + intensity_points +
  beginner_points + training_points + grooming_points + kids_points + health_points + outdoor_points) %>%

# Ranking the breeds from highest to lowest
arrange(desc(match_score))})

# Announce the top breed match
output$top_match <- renderText({
  top_dog <- matched_dogs() %>%
    slice_head(n = 1)
  paste("Your top match is the", top_dog$name, "with a match score of", round(top_dog$match_score, 1), "out of 50. Nice!")})

# Top 10 dog breed matches plot
output$match_plot <- renderPlot({

# 10 highest-ranked breeds
top_dogs <- matched_dogs() %>%
  slice_head(n = 10)

# Bar chart
ggplot(top_dogs,
  aes(x = reorder(name, match_score),
      y = match_score)) +
  geom_col(fill = "pink") +
  coord_flip() +
  labs(
    x = "Breed",
    y = "Match score (out of 50)") + theme_minimal()
  })

# Top 50 matches table
output$match_table <- renderTable({matched_dogs() %>%
  slice_head(n = 50) %>%
  select(Breed = name,
  Size = dog_size,
  `Average weight (lb)` = avg_weight,
  `Match score` = match_score,
  `Apartment suitability` = apartment_living,
  `Exercise needs` = exercise_need,
  `Training ease` = training_easiness,
  `Grooming ease` = groom_easiness,
  `Kid-friendliness` = kid_friendly,
  `General health` = general_health)})}

shinyApp(ui = ui, server = server)
