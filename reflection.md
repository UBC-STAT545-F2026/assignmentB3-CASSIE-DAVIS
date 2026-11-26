## Generative AI Statement 

Generative AI (through [ChatGPT)] was used to 
help me complete this assignment in the following ways:

1. Functions/techniques unique to ShinyApps, for example I wanted to learn how to make interactive dropdown menus using selectInput() and true/false boxes using checkboxInput() for my questionnaire

2. I needed explanatory paragraphs for the interface, and didn't know the Shiny lingo, so it helped me come up with p() and h3()

3. It helped me figure out that I need to use/how to use reactive() to make matched_dogs(), which recalcualtes the breed scores when the questionnaire is changed and has many outputs that depend on the same calculations

4. I wanted a reactive table and wasn't sure how to not just make a reactive graph, so AI helped me find and use tableOutput() and renderTable()

5. Made the top match message with textOutput() and renderText()

6. I needed to combine multiple inputs in the server like input$size and input$exercise, and needed it to be able to handle 10 preferences simultaneously

7. Customizing my layout, I wanted to put questions in the sidebar and the graph beside them so you could see how your answers change your results without scrolling down

8. I needed to assign categories and matching scores based on multiple conditions and wasn't sure out to input that, it helped me use case_when()

9. I needed to tie the descriptive questionnaire responses with numerical scoring with startsWith() in this way

10. It recommended pmax() when I realized I had to let some categories not match without penalization, like someone having a lot of activity time with a lower activity breed

11. I needed to handle the missing matching-point values without affecting calculations, so it suggested coalesce() and helped me add that in correctly



### AI Reflection

I enjoyed using AI in this assignment far more than I originally thought I would. It really gave me a lot of creative liberty over my project in a way that I haven't had before, and as I result I got pretty into it.
It definitely helped me learn some new functions and make sense of them in-context, which I found very helpful.

##### I consent to the use of this anonymized reflection outside of this assignment.
