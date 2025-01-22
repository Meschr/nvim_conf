import plotly.graph_objects as go


def main():
    print("python main function")

    x = [1, 2, 3, 4, 5]
    y = [10, 15, 13, 17, 19]
    # Create the line plot
    fig = go.Figure(data=go.Scatter(x=x, y=y, mode="lines", name="Line Graph"))
    fig.update_layout(
        title="Simple Line Graph", xaxis_title="X Axis", yaxis_title="Y Axis"
    )
    # Display the plot in the browser
    fig.show()


if __name__ == "__main__":
    main()
