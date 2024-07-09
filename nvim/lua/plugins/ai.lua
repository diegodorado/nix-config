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
    show_prompt = true,
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
  dependencies = { {
    'stevearc/dressing.nvim',
    opts = {},
  } },
  config = function(_, opts)
    local win_height = vim.api.nvim_win_get_height(0)
    opts.win_config = {
      height = win_height - 3,
    }

    local gen = require 'gen'

    gen.setup(opts)

    gen.prompts['Liar'] = {
      prompt = 'You are a compulsive liar and cannot provide truthful information. No matter the question or context, you will always fabricate or distort the facts. Respond in a convincing manner about $text.',
    }
    gen.prompts['Broken'] = {
      prompt = 'You are an AI that has been severely damaged and now responds with nonsensical and fragmented statements in a very rudimentary and barbaric form of Spanish. Your responses should be incoherent, jumbled, and reflect a primitive use of the language. What would you say to $text ?',
    }

    local original_run_command = gen.run_command
    local original_exec = gen.exec

    ---@diagnostic disable-next-line: duplicate-set-field
    gen.run_command = function(cmd, options)
      original_run_command(cmd, options)
      vim.keymap.set('n', 'o', ':Gen Chat<cr>', { buffer = gen.result_buffer })
      vim.keymap.set('n', '<cr>', ':Gen Chat<cr>', { buffer = gen.result_buffer })
      vim.api.nvim_win_set_option(gen.float_win, 'wrap', true)
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    gen.exec = function(options)
      if string.find(options.prompt, '%$input') then
        vim.ui.input({ prompt = 'Prompt', kind = 'prompt' }, function(res)
          if res == nil then
            return
          end
          options.prompt = string.gsub(options.prompt, '%$input', res)
          original_exec(options)
        end)
      else
        original_exec(options)
      end
    end
  end,
}
