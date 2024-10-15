local json = require("json")
local http = require("simplehttp")
local logger = require("log")


-- OpenAI API密钥
local api_key = "your_api_key"

local url = "https://api.openai.com/v1/chat/completions"

-- 设置请求头部信息，包括API密钥
local headers = {
    ["Authorization"] = "Bearer " .. api_key,
    ["Content-Type"] = "application/json",
}




local function translator(word, seg, env)

 
   -- 对话消息列表，这里可以添加初始的系统提示等
   local messages = {
      {
      role = "system",
      content = "你是一位中英翻译专家，当我输入中文时，请翻译为英文；当我输入英文时，请翻译为中文。除此之外，请不要回复任何无关的内容。"
      },
      {
         role = "user",
         content = word,
      }
   }

   -- 请求数据
   local data = {
      model = "one",
      messages = messages
   }

   local send_data = json.encode(data)


   logger.info(send_data)


   -- 发送POST请求到OpenAI的Completion API端点
   local r, c, h = http.request{
      url = url,
      method = "POST",
      headers = headers,
      data = send_data,
   }

   logger.info(c)
   logger.info(r)


   -- 检查状态码是否为200
   assert(c == 200, "Failed to get completion: " .. (r or "No response"))

   -- 解析响应内容（假设响应是JSON格式）
   local response = require("json").decode(r)
   local choices = response.choices

   local contents = choices[1].message.content

   if #choices > 0 then
      -- 打印AI的回复
      logger.info(contents)
   else
      logger.info("No response from AI.")
   end

   -- 假设Candidate类已经定义
   local c = Candidate("simple", seg.start, seg.start + #contents, contents, "(翻译)")
   c.quality = 2
   yield(c)
 end

return translator