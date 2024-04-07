declare global {
    interface Number {
        currency(decimal: boolean): string;
    }
}

Number.prototype.currency = function(decimal: boolean): string {
    if (decimal) {
        return Number(this).toFixed(2).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    } else {
        return Number(this).toFixed(0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
}

export {};
