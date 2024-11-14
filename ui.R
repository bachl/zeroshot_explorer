# ui.R
ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("OpenAI Content Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      # API Key
      passwordInput("api_key", "OpenAI API Key", width = "100%"),
      
      # System Prompt
      textAreaInput("system_prompt", "System Prompt", 
                    height = "150px", width = "100%",
                    value = "Your task is to evaluate whether a comment contains incivility."),
      
      # Coding Units
      textAreaInput("coding_units", "Coding Units (one per line)", 
                    height = "150px", width = "100%",
                    value = "Your dump and stupid!!$11!\nFor a woman, that was actually not bad."),
      
      # Model Parameters
      sliderInput("temperature", "Temperature",
                  min = 0, max = 2, value = 0, step = 0.1),
      
      numericInput("max_tokens", "Max Tokens",
                   value = 100, min = 1, step = 1),
      
      # Response Format Builder
      h4("Response Format"),
      
      # Label 1 (Required)
      numericInput("label1_min", "Label 1 Minimum", value = 0),
      numericInput("label1_max", "Label 1 Maximum", value = 1),
      textInput("label1_desc", "Label 1 Description", 
                value = "Binary code to indicate whether incivility is present (1) or not (0)"),
      
      # Label 2 (Optional)
      checkboxInput("use_label2", "Add Second Label", FALSE),
      conditionalPanel(
        condition = "input.use_label2 == true",
        numericInput("label2_min", "Label 2 Minimum", value = 0),
        numericInput("label2_max", "Label 2 Maximum", value = 1),
        textInput("label2_desc", "Label 2 Description")
      ),
      
      # Label 3 (Optional)
      checkboxInput("use_label3", "Add Third Label", FALSE),
      conditionalPanel(
        condition = "input.use_label3 == true && input.use_label2 == true",
        numericInput("label3_min", "Label 3 Minimum", value = 0),
        numericInput("label3_max", "Label 3 Maximum", value = 1),
        textInput("label3_desc", "Label 3 Description")
      ),
      
      actionButton("submit", "Process Comments", class = "btn-primary")
    ),
    
    mainPanel(
      tableOutput("results")
    )
  )
)
