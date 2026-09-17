function mod_clotho_get_random_level(arg0)
{
    if (arg0 == 1)
    {
        var r = irandom(99);
        
        if (r < 3)
            return 4;
        else if (r < 11)
            return 3;
        else if (r < 40)
            return 2;
        else
            return 1;
    }
    else if (arg0 == 2)
    {
        var r = irandom(99);
        
        if (r < 6)
            return 4;
        else if (r < 18)
            return 3;
        else if (r < 58)
            return 2;
        else
            return 1;
    }
    else if (arg0 == 3)
    {
        var r = irandom(99);
        
        if (r < 6)
            return 4;
        else if (r < 26)
            return 3;
        else if (r < 71)
            return 2;
        else
            return 1;
    }
    else
    {
        var r = irandom(99);
        
        if (r < 2)
            return 4;
        else if (r < 7)
            return 3;
        else if (r < 22)
            return 2;
        else if (r < 72)
            return 1;
        else if (r < 92)
            return -1;
        else
            return -2;
    }
}
