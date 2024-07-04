from huggingface_hub import hf_hub_download

model_id = "NESPED-GEN/phi-3-mini-128k-instruct-mix-spider-bird-1-epoch-gguf"
file= "Q8_0.gguf"
hf_hub_download(
    repo_id=model_id, filename=file, local_dir="models"
)