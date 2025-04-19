import torch

if __name__ == "__main__":
    print(f"There are {torch.cuda.device_count()} GPUs available")
