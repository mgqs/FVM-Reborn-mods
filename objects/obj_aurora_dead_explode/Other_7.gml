switch (shape_dead)
{
    case 1:
        timer = 10;
        break;
    
    case 2:
        timer = 10;
        break;
    
    case 3:
        // The final Aurora form has no post-animation hold frame.
        timer = 0;
        break;
    
    default:
        timer = 5;
}

can_destroy = true;
image_speed = 0;
