function  x = omp(A, y, errThresh)
    T=[]; % support set, T-> given in slides
    r=y; % Initialise the residual
    xsubs = zeros(size(A,2),1); % Column vector of zeroes of size (noOfCols in A) x 1
    count = 1;
    while norm(r)^2 > errThresh && count < size(A,2)
        dotprods = abs(A' * r);
        [~, b] = max(dotprods); % Get the index of the max dotproduct
        T = [T b]; % Extend the support set
        xfinal = pinv(A(:, T))*y; % Pseudo-inverse of A
        r = y-A(:,T) * xfinal; % Update the residual
        count = count + 1;
    end
    x = xsubs;
    x(T') = xfinal; % Store the reconstructed signal
end