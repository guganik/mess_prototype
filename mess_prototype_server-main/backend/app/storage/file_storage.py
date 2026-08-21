from pathlib import Path

class FileStorage:
    def __init__(self, root_path: str):
        self.root_path = Path(root_path)

        self.root_path.mkdir(
            parents=True,
            exist_ok=True
        )
    
    def save(self, file_id: str, extension: str, content: bytes) -> tuple[str, str]:
        stored_name = f'{file_id}{extension}'

        print(self.root_path, file_id, stored_name)

        file_path = self.root_path / file_id / stored_name

        file_path.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        file_path.write_bytes(content)

        return stored_name, str(file_path)

    def get(self, path: str) -> Path:
        file_path = Path(path)

        if not file_path.is_file(): raise FileNotFoundError(f'File not found: {path}')

        return file_path

    def delete(self, path: str) -> None:
        file_path = Path(path)

        if not file_path.exists(): return

        file_path.unlink()

        parent = file_path.parent

        if parent.exists() and not any(parent.iterdir()):
            parent.rmdir()