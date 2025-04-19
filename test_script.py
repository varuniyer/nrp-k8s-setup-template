import torch


def main():
    print(f"There are {torch.cuda.device_count()} GPUs available")


if __name__ == "__main__":
    main()
