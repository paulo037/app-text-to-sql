from huggingface_hub import hf_hub_download

model_id = "NESPED-GEN/stable-code-instruct-3b-mix-spider-bird-200-steps-gguf"
file= "Q8_0.gguf"
hf_hub_download(
    repo_id=model_id, filename=file, local_dir="models"
)