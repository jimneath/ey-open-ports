# EY Open Ports

A custom chef recipe that opens up ports for an environment by modifying the EC2 security group via the fog gem.

## How do I set which ports I wish to open?

Modify the `ports` array inside of `recipes/default.rb`:

https://github.com/jimneath/ey-open-ports/blob/master/recipes/default.rb#L2