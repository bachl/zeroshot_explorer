# server.R
library(shiny)
library(shinythemes)
library(httr2)
library(jsonlite)
library(tidyverse)

server <- function(input, output, session) {
  
  # Build response format based on user input
  build_response_format <- reactive({
    properties <- list(
      label1 = list(
        description = input$label1_desc,
        type = "integer",
        minimum = input$label1_min,
        maximum = input$label1_max
      ),
      mot1 = list(
        description = "Short text to explain the decision",
        type = "string"
      )
    )
    
    required <- c("label1", "mot1")
    
    if (input$use_label2) {
      properties$label2 <- list(
        description = input$label2_desc,
        type = "integer",
        minimum = input$label2_min,
        maximum = input$label2_max
      )
      properties$mot2 <- list(
        description = "Short text to explain the decision",
        type = "string"
      )
      required <- c(required, "label2", "mot2")
    }
    
    if (input$use_label3 && input$use_label2) {
      properties$label3 <- list(
        description = input$label3_desc,
        type = "integer",
        minimum = input$label3_min,
        maximum = input$label3_max
      )
      properties$mot3 <- list(
        description = "Short text to explain the decision",
        type = "string"
      )
      required <- c(required, "label3", "mot3")
    }
    
    list(
      type = "json_schema",
      json_schema = list(
        name = "content_coding",
        schema = list(
          type = "object",
          properties = properties,
          additionalProperties = FALSE,
          required = required
        )
      )
    )
  })
  
  # Process comments when submit button is clicked
  observeEvent(input$submit, {
    req(input$api_key, input$system_prompt, input$coding_units)
    
    withProgress(message = 'Processing comments', value = 0, {
      # Split coding units into vector
      cod <- strsplit(input$coding_units, "\n")[[1]]
      
      # Create base request
      req <- request(base_url = "https://api.openai.com/v1/chat/completions")
      
      # Create request list
      req_list <- cod |> 
        map(~ {
          req |> 
            req_auth_bearer_token(input$api_key) |> 
            req_body_json(list(
              model = "gpt-4o-mini",
              messages = list(
                list(role = "system", content = input$system_prompt),
                list(role = "user", content = .x)
              ),
              response_format = build_response_format(),
              temperature = input$temperature,
              max_tokens = input$max_tokens
            ))
        })
      
      # Perform requests
      resp_list <- req_list |> 
        req_perform_sequential()
      
      # Process results
      results <- resp_list |> 
        map_dfr(function(x) {
          tryCatch({
            x |> 
              resp_body_json() |> 
              _$choices |> 
              _[[1]] |> 
              _$message |> 
              _$content |> 
              fromJSON() |> 
              as_tibble()
          }, error = function(e) {
            # Create a tibble with the same structure as successful responses
            # but with NA/error messages
            tibble(
              !!!setNames(
                rep(list(NA), length(build_response_format()$json_schema$schema$required)),
                build_response_format()$json_schema$schema$required
              )) |> 
              mutate(across(starts_with('mot'), ~paste("Error processing response:", e$message)))
          })
        }) |> 
        mutate(comment = cod) |> 
        relocate(comment)
      
      # Display results
      output$results <- renderTable({
        results
      })
    })
  })
}
