def final(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    wrapper.__final__ = True
    return wrapper

