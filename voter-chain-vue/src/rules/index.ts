export function requiredLengthRule(min: number = -Infinity, max: number = Infinity) {
    return (value: string) => {
        if(value.length < min)
            return `This field should at least ${min} long`;
        else if(value.length > max)
            return `This field should be at most ${max} long`;
        else return true;
    }
}

export function requiredRule(value: string) {
    return value.length > 0 || "This field is required";
}