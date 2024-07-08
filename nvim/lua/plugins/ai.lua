-- Custom Parameters (with defaults)
return {
  'David-Kunz/gen.nvim',
  opts = {
    -- model = "mistral", -- The default model to use.
    model = 'llama3', -- The default model to use.
    host = 'localhost', -- The host running the Ollama service.
    port = '11434', -- The port on which the Ollama service is listening.
    retry_map = '<c-r>', -- set keymap to re-send the current prompt
    init = function(options)
      -- pcall(io.popen, 'ollama serve > /dev/null 2>&1 &')
    end,
    -- Function to initialize Ollama
    command = function(options)
      local body = { model = options.model, stream = true }
      return 'curl --silent --no-buffer -X POST http://' .. options.host .. ':' .. options.port .. '/api/chat -d $body'
    end,
    -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
    -- This can also be a command string.
    -- The executed command must return a JSON object with { response, context }
    -- (context property is optional).
    -- list_models = '<omitted lua function>', -- Retrieves a list of model names
  },
  keys = {
    { '<leader>aa', ':Gen<cr>', desc = 'Open [A]I options', mode = { 'n', 'v' } },
    { '<leader>ac', ':Gen Chat<cr>', desc = 'Chat with [A]I', mode = { 'n', 'v' } },
  },
}

-- make an AI chat with ollama
